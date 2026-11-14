import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/core/widgets/error_bottom_sheet.dart';
import 'package:spotshare/core/widgets/loading_button.dart';
import 'package:spotshare/features/auth/presentation/providers/auth_form_controller.dart';
import 'package:spotshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:spotshare/features/auth/presentation/widgets/auth_fields.dart';
import 'package:spotshare/i18n/strings.g.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;
    final signIn = ref.read(signInProvider);
    ref
        .read(loginControllerProvider.notifier)
        .submit(
          () => signIn(email: _email.text.trim(), password: _password.text),
        );
  }

  void _signInWithGoogle() {
    final signInWithGoogle = ref.read(signInWithGoogleProvider);
    ref.read(loginControllerProvider.notifier).submit(signInWithGoogle.call);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.login;
    final spacing = context.appTheme.spacing;
    ref.listen(loginControllerProvider, (_, next) {
      if (next case AsyncError(:final Failure error)) {
        showErrorBottomSheet(context, error);
      }
    });
    final isLoading = ref.watch(loginControllerProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: Text(t.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.spacingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: spacing.spacingS,
              children: [
                EmailField(controller: _email),
                PasswordField(controller: _password, onSubmitted: _signIn),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.forgotPassword),
                    child: Text(t.forgotPassword),
                  ),
                ),
                LoadingButton(
                  label: t.submit,
                  isLoading: isLoading,
                  onPressed: _signIn,
                ),
                OutlinedButton(
                  onPressed: isLoading ? null : _signInWithGoogle,
                  child: Text(context.t.auth.continueWithGoogle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
