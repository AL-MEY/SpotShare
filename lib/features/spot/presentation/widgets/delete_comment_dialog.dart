import 'package:flutter/material.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/i18n/strings.g.dart';

Future<bool> showDeleteCommentDialog(BuildContext context) async {
  final t = context.t.spot.comments;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(t.deleteTitle),
      content: Text(t.deleteMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(t.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: dialogContext.appTheme.colors.error,
          ),
          child: Text(t.delete),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
