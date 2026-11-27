import 'package:flutter/material.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/error/failure_message.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/i18n/strings.g.dart';

class SpotLoadError extends StatelessWidget {
  const SpotLoadError({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = context.appTheme;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: theme.spacing.spacingS,
            children: [
              Text(failure.title(t), style: theme.textStyles.h3),
              Text(
                failure.message(t),
                textAlign: TextAlign.center,
                style: theme.textStyles.b2.copyWith(
                  color: theme.colors.foregroundMuted,
                ),
              ),
              FilledButton(onPressed: onRetry, child: Text(t.errors.retry)),
            ],
          ),
        ),
      ),
    );
  }
}
