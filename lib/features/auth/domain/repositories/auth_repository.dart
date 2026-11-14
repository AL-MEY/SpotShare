import 'package:spotshare/features/auth/domain/entities/app_user.dart';

abstract interface class AuthRepository {
  AppUser? get currentUser;

  Stream<AppUser?> watchUser();

  Future<void> signIn({required String email, required String password});

  Future<void> signInWithGoogle();

  Future<void> signUp({required String email, required String password});

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);
}
