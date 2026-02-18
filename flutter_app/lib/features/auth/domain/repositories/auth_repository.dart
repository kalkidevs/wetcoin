import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<Either<Failure, User>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
}
