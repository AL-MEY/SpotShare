import 'package:firebase_core/firebase_core.dart';
import 'package:spotshare/core/error/failure.dart';

Failure failureFrom(Object error) => switch (error) {
  Failure() => error,
  FirebaseException(
    code: 'unavailable' || 'deadline-exceeded' || 'network-request-failed',
  ) =>
    const NetworkFailure(),
  FirebaseException(code: 'unauthenticated') => const UnauthenticatedFailure(),
  FirebaseException(code: 'permission-denied' || 'unauthorized') =>
    const PermissionFailure(),
  FirebaseException(code: 'not-found' || 'object-not-found') =>
    const NotFoundFailure(),
  _ => UnknownFailure(error),
};
