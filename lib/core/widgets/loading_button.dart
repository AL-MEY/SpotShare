import 'package:flutter/material.dart';
import 'package:spotshare/core/theme/app_theme.dart';

class LoadingButton extends StatelessWidget {
  const LoadingButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox.square(
              dimension: theme.spacing.spacingL,
              child: CircularProgressIndicator(
                strokeWidth: theme.stroke.strokeM,
              ),
            )
          : Text(label),
    );
  }
}
