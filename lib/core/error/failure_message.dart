import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/i18n/strings.g.dart';

extension FailureMessage on Failure {
  String title(Translations t) => switch (this) {
    NetworkFailure() => t.errors.network.title,
    UnauthenticatedFailure() => t.errors.unauthenticated.title,
    PermissionFailure() => t.errors.permissionDenied.title,
    NotFoundFailure() => t.errors.notFound.title,
    InvalidCredentialsFailure() => t.errors.invalidCredentials.title,
    EmailAlreadyUsedFailure() => t.errors.emailAlreadyUsed.title,
    WeakPasswordFailure() => t.errors.weakPassword.title,
    UnknownFailure() => t.errors.unknown.title,
  };

  String message(Translations t) => switch (this) {
    NetworkFailure() => t.errors.network.message,
    UnauthenticatedFailure() => t.errors.unauthenticated.message,
    PermissionFailure() => t.errors.permissionDenied.message,
    NotFoundFailure() => t.errors.notFound.message,
    InvalidCredentialsFailure() => t.errors.invalidCredentials.message,
    EmailAlreadyUsedFailure() => t.errors.emailAlreadyUsed.message,
    WeakPasswordFailure() => t.errors.weakPassword.message,
    UnknownFailure() => t.errors.unknown.message,
  };
}
