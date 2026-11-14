import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/features/auth/presentation/providers/auth_form_controller.dart';

void main() {
  late ProviderContainer container;
  late List<AsyncValue<void>> states;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    states = [];
    container.listen(
      loginControllerProvider,
      (_, next) => states.add(next),
      fireImmediately: true,
    );
  });

  test('passe de initial à loading puis data quand l’action réussit', () async {
    await container.read(loginControllerProvider.notifier).submit(() async {});

    expect(states, [
      isA<AsyncData<void>>(),
      isA<AsyncLoading<void>>(),
      isA<AsyncData<void>>(),
    ]);
  });

  test('passe à error avec la Failure levée par l’action', () async {
    await container
        .read(loginControllerProvider.notifier)
        .submit(() async => throw const NetworkFailure());

    expect(states.last.error, isA<NetworkFailure>());
  });
}
