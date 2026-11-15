import 'package:flutter/material.dart';
import 'package:spotshare/features/profile/domain/entities/user_profile.dart';
import 'package:spotshare/i18n/strings.g.dart';

class BioField extends StatelessWidget {
  const BioField({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final t = context.t.profile;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: t.bio, hintText: t.bioHint),
      maxLength: UserProfile.bioMaxLength,
      minLines: 2,
      maxLines: 4,
      textCapitalization: TextCapitalization.sentences,
    );
  }
}
