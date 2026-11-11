import 'dart:async';

import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/features/auth/domain/entities/app_user.dart';
import 'package:spotshare/features/auth/domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository([this._user]);

  static const user = AppUser(id: 'uid', email: 'test@spotshare.app');

  AppUser? _user;
  Failure? googleFailure;
  final _controller = StreamController<AppUser?>.broadcast();

  void emit(AppUser? user) {
    _user = user;
    _controller.add(user);
  }

  Future<void> dispose() => _controller.close();

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> watchUser() => _controller.stream;

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async => emit(user);

  @override
  Future<void> signInWithGoogle() async {
    final failure = googleFailure;
    if (failure != null) throw failure;
    emit(user);
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) async => emit(user);

  @override
  Future<void> signOut() async => emit(null);

  @override
  Future<void> sendPasswordResetEmail(String email) async {}
}
