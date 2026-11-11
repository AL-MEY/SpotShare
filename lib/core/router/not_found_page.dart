import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/error/failure_message.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/i18n/strings.g.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: context.appTheme.spacing.spacingS,
            children: [
              Text(const NotFoundFailure().message(t)),
              TextButton(
                onPressed: () => context.go(AppRoutes.home),
                child: Text(t.errors.backHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
