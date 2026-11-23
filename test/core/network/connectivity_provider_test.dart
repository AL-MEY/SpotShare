import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotshare/core/network/connectivity_provider.dart';

class _MockConnectivity extends Mock implements Connectivity {}

void main() {
  late _MockConnectivity connectivity;
  late StreamController<List<ConnectivityResult>> changes;
  late ProviderContainer container;

  setUp(() {
    connectivity = _MockConnectivity();
    changes = StreamController<List<ConnectivityResult>>();
    addTearDown(changes.close);
    when(() => connectivity.onConnectivityChanged)
        .thenAnswer((_) => changes.stream);
    container = ProviderContainer(
      overrides: [connectivityProvider.overrideWithValue(connectivity)],
    );
    addTearDown(container.dispose);
  });

  Future<bool> firstValue() {
    container.listen(isOnlineProvider, (_, _) {});
    return container.read(isOnlineProvider.future);
  }

  void givenInitial(List<ConnectivityResult> results) =>
      when(() => connectivity.checkConnectivity())
          .thenAnswer((_) async => results);

  test('en ligne quand le wifi est disponible', () async {
    givenInitial([ConnectivityResult.wifi]);

    expect(await firstValue(), isTrue);
  });

  test('hors ligne quand aucune connexion', () async {
    givenInitial([ConnectivityResult.none]);

    expect(await firstValue(), isFalse);
  });

  test('suit les changements de connexion', () async {
    givenInitial([ConnectivityResult.wifi]);
    final values = <bool>[];
    container.listen(isOnlineProvider, (_, next) {
      final value = next.value;
      if (value != null) values.add(value);
    });
    await container.read(isOnlineProvider.future);

    changes.add([ConnectivityResult.none]);
    await Future<void>.delayed(Duration.zero);
    changes.add([ConnectivityResult.mobile, ConnectivityResult.vpn]);
    await Future<void>.delayed(Duration.zero);

    expect(values, [true, false, true]);
  });

  test(
    'ne perd pas un changement survenu pendant la vérification initiale',
    () async {
      final initial = Completer<List<ConnectivityResult>>();
      when(() => connectivity.checkConnectivity())
          .thenAnswer((_) => initial.future);
      final values = <bool>[];
      container.listen(isOnlineProvider, (_, next) {
        final value = next.value;
        if (value != null) values.add(value);
      });
      await Future<void>.delayed(Duration.zero);

      changes.add([ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);
      initial.complete([ConnectivityResult.wifi]);
      await Future<void>.delayed(Duration.zero);

      expect(values, [false]);
    },
  );

  test('propage une erreur du flux de connectivité', () async {
    givenInitial([ConnectivityResult.wifi]);
    container.listen(isOnlineProvider, (_, _) {});
    await container.read(isOnlineProvider.future);

    changes.addError(StateError('boom'));
    await Future<void>.delayed(Duration.zero);

    expect(container.read(isOnlineProvider).hasError, isTrue);
  });
}
