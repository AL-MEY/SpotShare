import 'package:flutter/material.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/error/failure_message.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/i18n/strings.g.dart';

Future<void> showErrorBottomSheet(
  BuildContext context,
  Failure failure, {
  VoidCallback? onRetry,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => ErrorBottomSheet(failure: failure, onRetry: onRetry),
  );
}

class ErrorBottomSheet extends StatelessWidget {
  const ErrorBottomSheet({required this.failure, this.onRetry, super.key});

  final Failure failure;
  final VoidCallback? onRetry;

  IconData get _icon => switch (failure) {
    NetworkFailure() => Icons.wifi_off,
    UnauthenticatedFailure() => Icons.lock_outline,
    PermissionFailure() => Icons.block,
    NotFoundFailure() => Icons.search_off,
    InvalidCredentialsFailure() => Icons.key_off,
    EmailAlreadyUsedFailure() => Icons.alternate_email,
    WeakPasswordFailure() => Icons.password,
    UnknownFailure() => Icons.error_outline,
  };

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = context.appTheme;
    final onRetry = this.onRetry;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: theme.spacing.spacingS,
          children: [
            Icon(_icon, color: theme.colors.error),
            Text(
              failure.title(t),
              style: theme.textStyles.h3,
              textAlign: TextAlign.center,
            ),
            Text(
              failure.message(t),
              style: theme.textStyles.b2.copyWith(
                color: theme.colors.foregroundMuted,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null)
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: Text(t.errors.retry),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.errors.close),
            ),
          ],
        ),
      ),
    );
  }
}
