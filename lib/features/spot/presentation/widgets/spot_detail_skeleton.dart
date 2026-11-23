import 'package:flutter/material.dart';
import 'package:spotshare/core/theme/app_theme.dart';

class SpotDetailSkeleton extends StatelessWidget {
  const SpotDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.appTheme.spacing;
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    Widget block(double height, [double? width]) => Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(spacing.spacingXs),
      ),
    );
    return ExcludeSemantics(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spacing.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.spacingM,
            children: [
              block(240),
              block(28, 220),
              block(16, 140),
              block(16),
              block(16),
            ],
          ),
        ),
      ),
    );
  }
}
