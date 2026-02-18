import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Repository for managing user data in Firestore
class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';

  /// Creates or updates a user document in Firestore
  /// This is called on first login to create the user profile
  Future<void> createUserDocument(User firebaseUser) async {
    try {
      final userRef =
          _firestore.collection(_usersCollection).doc(firebaseUser.uid);

      // Check if user document already exists
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        // Create new user document with initial data
        await userRef.set({
          'uid': firebaseUser.uid,
          'name': firebaseUser.displayName ?? 'User',
          'email': firebaseUser.email ?? '',
          'photoUrl': firebaseUser.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'balance': 0,
          'lastSyncAt': null,
        }, SetOptions(merge: true));
      } else {
        // Update existing user with latest info
        await userRef.update({
          'name': firebaseUser.displayName ?? 'User',
          'email': firebaseUser.email ?? '',
          'photoUrl': firebaseUser.photoURL ?? '',
        });
      }
    } on FirebaseException catch (e) {
      throw UserRepositoryException(
        e.code,
        'Failed to create user document: ${e.message}',
      );
    } catch (e) {
      throw UserRepositoryException(
        'unknown',
        'Failed to create user document: ${e.toString()}',
      );
    }
  }

  /// Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final userDoc =
          await _firestore.collection(_usersCollection).doc(uid).get();
      return userDoc.data();
    } on FirebaseException catch (e) {
      throw UserRepositoryException(
        e.code,
        'Failed to get user data: ${e.message}',
      );
    }
  }

  /// Update user coins balance
  Future<void> updateCoinsBalance(String uid, int newBalance) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'balance': newBalance,
      });
    } on FirebaseException catch (e) {
      throw UserRepositoryException(
        e.code,
        'Failed to update coins balance: ${e.message}',
      );
    }
  }

  /// Update last sync timestamp
  Future<void> updateLastSyncAt(String uid) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'lastSyncAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw UserRepositoryException(
        e.code,
        'Failed to update last sync: ${e.message}',
      );
    }
  }
}

/// Custom exception for user repository errors
class UserRepositoryException implements Exception {
  final String code;
  final String message;

  UserRepositoryException(this.code, this.message);

  @override
  String toString() => message;
}
