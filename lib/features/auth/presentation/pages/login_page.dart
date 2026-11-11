import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/core/widgets/error_bottom_sheet.dart';
import 'package:spotshare/features/auth/presentation/providers/google_sign_in_controller.dart';
import 'package:spotshare/i18n/strings.g.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t.login;
    ref.listen(googleSignInControllerProvider, (_, next) {
      if (next case AsyncError(:final Failure error)) {
        showErrorBottomSheet(context, error);
      }
    });
    final isLoading = ref.watch(googleSignInControllerProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: Text(t.title)),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.appTheme.spacing.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton(
                onPressed: isLoading
                    ? null
                    : ref.read(googleSignInControllerProvider.notifier).signIn,
                child: Text(t.continueWithGoogle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
