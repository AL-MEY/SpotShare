import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubmitController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submit(Future<void> Function() action) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(action);
    if (ref.mounted) state = result;
  }
}
