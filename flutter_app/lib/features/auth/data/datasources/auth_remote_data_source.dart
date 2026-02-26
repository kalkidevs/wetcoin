import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sweatcoin/core/utils/logger.dart';
import '../repositories/user_repository.dart';
import '../datasources/auth_backend_service.dart';

/// Provider for the AuthService
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Provider for the current authenticated user
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// AuthService handles all authentication operations using Google Sign-In
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Use the web client ID from Firebase (found in Firebase Console → Project Settings → Your apps)
  // This is the OAuth 2.0 Client ID for Web
  static const String _serverClientId =
      '855783111361-4rq7b5a9fu7crijq8qusp1vbghaak2rq.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn;
  final UserRepository _userRepository = UserRepository();
  final AuthBackendService _backendService = AuthBackendService();

  AuthService() {
    // Initialize GoogleSignIn with the server client ID
    _googleSignIn = GoogleSignIn(
      serverClientId: _serverClientId,
    );
    debugPrint(
        '[AuthService] Initialized with serverClientId: $_serverClientId');
  }

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get the currently signed-in user
  User? get currentUser => _auth.currentUser;

  /// Sign in with Google
  /// Returns the Firebase UserCredential on success
  /// Throws exceptions on failure
  Future<UserCredential> signInWithGoogle() async {
    try {
      AppLogger.section('GOOGLE SIGN-IN FLOW');
      AppLogger.userState(
          'SIGN_IN_START', 'unknown', 'Starting Google Sign-In');
      AppLogger.firebase('GOOGLE_SIGN_IN', 'Starting Google Sign-In flow');
      AppLogger.config('SERVER_CLIENT_ID', _serverClientId);

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      AppLogger.auth(
          'GOOGLE_SIGN_IN_RESULT',
          googleUser != null
              ? 'User selected: ${googleUser.email}'
              : 'User cancelled Google Sign-In');

      // Handle user cancellation
      if (googleUser == null) {
        AppLogger.warn(
            'AUTH_CANCELLED', 'Google Sign-In was cancelled by the user');
        throw AuthException(
          'cancelled',
          'Google Sign-In was cancelled by the user',
        );
      }

      // Obtain the auth details from the Google Sign-In
      AppLogger.auth('GETTING_AUTH_DETAILS',
          'Getting auth details for: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      AppLogger.auth(
          'TOKENS_RECEIVED',
          'Access token: ${googleAuth.accessToken?.substring(0, 10) ?? "null"}... '
              'ID token: ${googleAuth.idToken?.substring(0, 20) ?? "null"}...');

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      AppLogger.auth(
          'FIREBASE_SIGN_IN', 'Signing in to Firebase with credential...');

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      AppLogger.auth('FIREBASE_SIGN_IN_SUCCESS',
          'Firebase sign-in successful: ${userCredential.user?.email}');

      // Create user document in Firestore on first login
      if (userCredential.user != null) {
        AppLogger.auth('FIRESTORE_USER_CREATION',
            'Creating user document in Firestore...');
        await _userRepository.createUserDocument(userCredential.user!);
        AppLogger.auth(
            'FIRESTORE_USER_CREATED', 'User document created successfully');

        // Sync user with backend MongoDB
        AppLogger.auth(
            'MONGODB_SYNC_START', 'Syncing user with backend MongoDB...');
        try {
          // Get the Firebase ID token to send to backend
          final idToken = await userCredential.user!.getIdToken();
          if (idToken != null) {
            final backendResult = await _backendService.verifyToken(idToken);
            if (backendResult['success'] == true) {
              AppLogger.auth('MONGODB_SYNC_SUCCESS',
                  'User synced with MongoDB successfully');
            } else {
              AppLogger.warn('MONGODB_SYNC_FAILED',
                  'Failed to sync user with MongoDB: ${backendResult['error']}');
            }
          } else {
            AppLogger.warn(
                'MONGODB_SYNC_FAILED', 'Failed to get Firebase ID token');
          }
        } catch (e) {
          AppLogger.error(
              'MONGODB_SYNC_ERROR', 'Error syncing user with MongoDB: $e');
        }
      }

      AppLogger.userState(
          'SIGN_IN_SUCCESS',
          userCredential.user?.uid ?? 'unknown',
          userCredential.user?.email ?? 'unknown');
      AppLogger.auth('AUTH_SUCCESS', 'User authenticated successfully');

      return userCredential;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('FIREBASE_AUTH_ERROR',
          'FirebaseAuthException: ${e.code} - ${e.message}');
      throw AuthException(
        e.code,
        _getFirebaseAuthErrorMessage(e.code),
      );
    } catch (e, stackTrace) {
      AppLogger.error('AUTH_UNKNOWN_ERROR',
          'Unknown error during authentication: $e', stackTrace);
      throw AuthException(
        'unknown',
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Sign out from both Google and Firebase
  Future<void> signOut() async {
    try {
      debugPrint('[AuthService] Signing out...');
      // Sign out from Google first
      await _googleSignIn.signOut();
      // Then sign out from Firebase
      await _auth.signOut();
      debugPrint('[AuthService] Signed out successfully');
    } catch (e) {
      debugPrint('[AuthService] Sign out error: $e');
      throw AuthException(
        'sign_out_error',
        'Failed to sign out: ${e.toString()}',
      );
    }
  }

  /// Get error message for Firebase Auth errors
  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'user-disabled':
        return 'This user account has been disabled';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Invalid password';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'ERROR_INVALID_CREDENTIALS':
        return 'Invalid credentials. Please try again';
      case 'ERROR_SERVER_ERROR':
        return 'Server error. Please try again later';
      default:
        return 'Authentication failed: $code';
    }
  }
}

/// Custom exception class for authentication errors
class AuthException implements Exception {
  final String code;
  final String message;

  AuthException(this.code, this.message);

  @override
  String toString() => message;
}
