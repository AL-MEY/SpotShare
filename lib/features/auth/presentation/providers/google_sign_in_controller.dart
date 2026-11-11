import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/features/auth/presentation/providers/auth_providers.dart';

final googleSignInControllerProvider =
    AsyncNotifierProvider.autoDispose<GoogleSignInController, void>(
      GoogleSignInController.new,
    );

class GoogleSignInController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signIn() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      ref.read(signInWithGoogleProvider).call,
    );
    if (ref.mounted) state = result;
  }
}
