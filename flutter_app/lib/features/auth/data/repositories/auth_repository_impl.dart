import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthRepositoryImpl(authService);
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  @override
  User? get currentUser => _authService.currentUser;

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential.user != null) {
        return Right(credential.user!);
      } else {
        return const Left(AuthFailure('User not found after sign in'));
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _authService.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
