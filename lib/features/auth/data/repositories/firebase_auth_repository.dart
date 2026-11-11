import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/error/firebase_failure.dart';
import 'package:spotshare/features/auth/domain/entities/app_user.dart';
import 'package:spotshare/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  const FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Stream<AppUser?> watchUser() => _auth.authStateChanges().map(_toAppUser);

  @override
  Future<void> signIn({required String email, required String password}) =>
      _guard(
        () =>
            _auth.signInWithEmailAndPassword(email: email, password: password),
      );

  @override
  Future<void> signUp({required String email, required String password}) =>
      _guard(
        () => _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ),
      );

  @override
  Future<void> signOut() => _guard(_auth.signOut);

  @override
  Future<void> sendPasswordResetEmail(String email) => _guard(() async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code != 'user-not-found') rethrow;
    }
  });
}

AppUser? _toAppUser(User? user) =>
    user == null ? null : AppUser(id: user.uid, email: user.email ?? '');

Future<void> _guard(Future<void> Function() action) async {
  try {
    await action();
  } catch (e) {
    throw _authFailure(e);
  }
}

Failure _authFailure(Object error) => switch (error) {
  FirebaseAuthException(
    code: 'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' ||
        'invalid-email',
  ) =>
    const InvalidCredentialsFailure(),
  FirebaseAuthException(code: 'email-already-in-use') =>
    const EmailAlreadyUsedFailure(),
  FirebaseAuthException(code: 'weak-password') => const WeakPasswordFailure(),
  _ => failureFrom(error),
};
