import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/error/firebase_failure.dart';

FirebaseException _firebase(String code) =>
    FirebaseException(plugin: 'test', code: code);

void main() {
  test('convertit les codes Firebase communs en Failure typée', () {
    expect(failureFrom(_firebase('unavailable')), isA<NetworkFailure>());
    expect(
      failureFrom(_firebase('network-request-failed')),
      isA<NetworkFailure>(),
    );
    expect(
      failureFrom(_firebase('unauthenticated')),
      isA<UnauthenticatedFailure>(),
    );
    expect(
      failureFrom(_firebase('permission-denied')),
      isA<PermissionFailure>(),
    );
    expect(failureFrom(_firebase('not-found')), isA<NotFoundFailure>());
  });

  test('laisse passer une Failure déjà typée', () {
    const failure = NotFoundFailure();

    expect(failureFrom(failure), same(failure));
  });

  test('renvoie UnknownFailure avec la cause pour le reste', () {
    final error = StateError('boom');

    final failure = failureFrom(error);

    expect(failure, isA<UnknownFailure>());
    expect((failure as UnknownFailure).cause, same(error));
  });
}
