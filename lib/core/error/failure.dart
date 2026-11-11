sealed class Failure implements Exception {
  const Failure();
}

final class NetworkFailure extends Failure {
  const NetworkFailure();
}

final class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure();
}

final class PermissionFailure extends Failure {
  const PermissionFailure();
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure();
}

final class UnknownFailure extends Failure {
  const UnknownFailure([this.cause]);

  final Object? cause;
}
