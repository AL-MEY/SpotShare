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

final class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure();
}

final class EmailAlreadyUsedFailure extends Failure {
  const EmailAlreadyUsedFailure();
}

final class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure();
}

final class UnknownFailure extends Failure {
  const UnknownFailure([this.cause]);

  final Object? cause;
}
