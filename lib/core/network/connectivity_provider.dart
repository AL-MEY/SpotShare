import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

bool _isOnline(List<ConnectivityResult> results) =>
    results.any((result) => result != ConnectivityResult.none);

final isOnlineProvider = StreamProvider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  final controller = StreamController<bool>();
  var changed = false;

  // Abonnement avant la vérification : un changement entre les deux serait perdu.
  final subscription = connectivity.onConnectivityChanged.listen((results) {
    changed = true;
    controller.add(_isOnline(results));
  });
  connectivity.checkConnectivity().then((results) {
    if (!changed && !controller.isClosed) controller.add(_isOnline(results));
  }, onError: controller.addError);

  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });
  return controller.stream;
});
