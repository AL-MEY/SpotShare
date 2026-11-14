import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/i18n/strings.g.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t.onboarding;
    final theme = context.appTheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: theme.spacing.spacingS,
            children: [
              const Spacer(),
              Text(
                t.title,
                style: theme.textStyles.h1,
                textAlign: TextAlign.center,
              ),
              Text(
                t.subtitle,
                style: theme.textStyles.b1.copyWith(
                  color: theme.colors.foregroundMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.push(AppRoutes.signUp),
                child: Text(t.next),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
