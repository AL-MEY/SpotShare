import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/core/widgets/error_bottom_sheet.dart';
import 'package:spotshare/core/widgets/loading_button.dart';
import 'package:spotshare/features/auth/presentation/providers/auth_form_controller.dart';
import 'package:spotshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:spotshare/features/auth/presentation/widgets/auth_fields.dart';
import 'package:spotshare/i18n/strings.g.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _send() {
    if (!_formKey.currentState!.validate()) return;
    final sendResetEmail = ref.read(sendPasswordResetEmailProvider);
    ref
        .read(passwordResetControllerProvider.notifier)
        .submit(() => sendResetEmail(_email.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.forgotPassword;
    final theme = context.appTheme;
    ref.listen(passwordResetControllerProvider, (previous, next) {
      switch (next) {
        case AsyncError(:final Failure error):
          showErrorBottomSheet(context, error);
        case AsyncData() when previous?.isLoading ?? false:
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(t.sent)));
          context.pop();
        default:
      }
    });
    return Scaffold(
      appBar: AppBar(title: Text(t.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(theme.spacing.spacingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: theme.spacing.spacingS,
              children: [
                Text(
                  t.hint,
                  style: theme.textStyles.b2.copyWith(
                    color: theme.colors.foregroundMuted,
                  ),
                ),
                EmailField(controller: _email),
                LoadingButton(
                  label: t.submit,
                  isLoading: ref
                      .watch(passwordResetControllerProvider)
                      .isLoading,
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
