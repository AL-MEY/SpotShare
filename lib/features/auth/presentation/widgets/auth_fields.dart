import 'package:flutter/material.dart';
import 'package:spotshare/i18n/strings.g.dart';

const minPasswordLength = 6;

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class EmailField extends StatelessWidget {
  const EmailField({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final t = context.t.auth;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: t.email),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      validator: (value) =>
          _emailPattern.hasMatch(value?.trim() ?? '') ? null : t.invalidEmail,
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.controller,
    this.isNewPassword = false,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final bool isNewPassword;
  final VoidCallback? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  var _obscured = true;

  String? _validate(String? value) {
    final t = context.t.auth;
    final password = value ?? '';
    if (password.isEmpty) return t.passwordRequired;
    if (widget.isNewPassword && password.length < minPasswordLength) {
      return t.passwordTooShort(min: minPasswordLength);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.auth;
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      decoration: InputDecoration(
        labelText: t.password,
        suffixIcon: IconButton(
          tooltip: _obscured ? t.showPassword : t.hidePassword,
          icon: Icon(_obscured ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
      ),
      textInputAction: TextInputAction.done,
      autofillHints: [
        widget.isNewPassword
            ? AutofillHints.newPassword
            : AutofillHints.password,
      ],
      onFieldSubmitted: (_) => widget.onSubmitted?.call(),
      validator: _validate,
    );
  }
}
