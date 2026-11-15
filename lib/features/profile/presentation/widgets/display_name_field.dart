import 'package:flutter/material.dart';
import 'package:spotshare/features/profile/domain/entities/user_profile.dart';
import 'package:spotshare/i18n/strings.g.dart';

class DisplayNameField extends StatelessWidget {
  const DisplayNameField({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final t = context.t.profile;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: t.displayName),
      maxLength: UserProfile.displayNameMaxLength,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      autofillHints: const [AutofillHints.nickname],
      validator: (value) =>
          (value?.trim().length ?? 0) < UserProfile.displayNameMinLength
          ? t.displayNameTooShort(min: UserProfile.displayNameMinLength)
          : null,
    );
  }
}
