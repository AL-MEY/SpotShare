import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginControllerProvider =
    AsyncNotifierProvider.autoDispose<AuthFormController, void>(
      AuthFormController.new,
    );

final signUpControllerProvider =
    AsyncNotifierProvider.autoDispose<AuthFormController, void>(
      AuthFormController.new,
    );

final passwordResetControllerProvider =
    AsyncNotifierProvider.autoDispose<AuthFormController, void>(
      AuthFormController.new,
    );

class AuthFormController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submit(Future<void> Function() action) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(action);
    if (ref.mounted) state = result;
  }
}
