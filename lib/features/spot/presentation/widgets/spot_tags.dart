import 'package:flutter/material.dart';
import 'package:spotshare/core/theme/app_theme.dart';

class SpotTags extends StatelessWidget {
  const SpotTags({super.key, required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Wrap(
      spacing: theme.spacing.spacingXs,
      runSpacing: theme.spacing.spacingXs,
      children: [
        for (final tag in tags)
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colors.border),
              borderRadius: BorderRadius.circular(theme.radius.full),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacing.spacingS,
                vertical: theme.spacing.spacing2xs,
              ),
              child: Text('#$tag', style: theme.textStyles.b3),
            ),
          ),
      ],
    );
  }
}
