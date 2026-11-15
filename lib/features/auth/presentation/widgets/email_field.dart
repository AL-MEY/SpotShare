import 'package:flutter/material.dart';
import 'package:spotshare/i18n/strings.g.dart';

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
