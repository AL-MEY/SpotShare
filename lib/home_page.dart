import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:spotshare/i18n/strings.g.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t.home;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: context.appTheme.spacing.spacingS,
            children: [
              Text(t.welcome, style: textTheme.headlineSmall),
              Text(t.subtitle, style: textTheme.bodyMedium),
              TextButton(
                onPressed: () => ref.read(signOutProvider)(),
                child: Text(t.signOut),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
