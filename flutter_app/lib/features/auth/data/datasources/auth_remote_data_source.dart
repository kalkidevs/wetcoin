import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../repositories/user_repository.dart';

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
      debugPrint('[AuthService] Starting Google Sign-In...');
      debugPrint('[AuthService] Using serverClientId: $_serverClientId');

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      debugPrint(
          '[AuthService] Google Sign-In result: ${googleUser?.email ?? "null (cancelled)"}');
      debugPrint('[AuthService] Google User ID: ${googleUser?.id}');

      // Handle user cancellation
      if (googleUser == null) {
        throw AuthException(
          'cancelled',
          'Google Sign-In was cancelled by the user',
        );
      }

      // Obtain the auth details from the Google Sign-In
      debugPrint('[AuthService] Getting auth details for: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      debugPrint(
          '[AuthService] Access token: ${googleAuth.accessToken?.substring(0, 10) ?? "null"}...');
      debugPrint(
          '[AuthService] ID token: ${googleAuth.idToken?.substring(0, 20) ?? "null"}...');

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('[AuthService] Signing in to Firebase with credential...');

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      debugPrint(
          '[AuthService] Firebase sign-in successful: ${userCredential.user?.email}');

      // Create user document in Firestore on first login
      if (userCredential.user != null) {
        debugPrint('[AuthService] Creating user document in Firestore...');
        await _userRepository.createUserDocument(userCredential.user!);
        debugPrint('[AuthService] User document created successfully');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint(
          '[AuthService] FirebaseAuthException: ${e.code} - ${e.message}');
      throw AuthException(
        e.code,
        _getFirebaseAuthErrorMessage(e.code),
      );
    } catch (e, stackTrace) {
      debugPrint('[AuthService] Unknown error: $e');
      debugPrint('[AuthService] Stack trace: $stackTrace');
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
