import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/error/failure_message.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:spotshare/features/profile/presentation/providers/profile_providers.dart';
import 'package:spotshare/i18n/strings.g.dart';

class ProfileLoadError extends ConsumerWidget {
  const ProfileLoadError({super.key, required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = context.appTheme;
    return Padding(
      padding: EdgeInsets.all(theme.spacing.spacingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: theme.spacing.spacingS,
        children: [
          Text(failure.title(t), style: theme.textStyles.h3),
          Text(failure.message(t), textAlign: TextAlign.center),
          FilledButton(
            onPressed: () => ref.invalidate(currentProfileProvider),
            child: Text(t.errors.retry),
          ),
          TextButton(
            onPressed: () => ref.read(signOutProvider)(),
            child: Text(t.profile.signOut),
          ),
        ],
      ),
    );
  }
}
