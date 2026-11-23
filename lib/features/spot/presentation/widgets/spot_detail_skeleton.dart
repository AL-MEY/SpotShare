import 'package:flutter/material.dart';
import 'package:spotshare/core/theme/app_theme.dart';

class SpotDetailSkeleton extends StatelessWidget {
  const SpotDetailSkeleton({super.key});

  static const _galleryHeight = 240.0;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final spacing = theme.spacing;
    final color = theme.colors.surfaceMuted;
    Widget block(double height, [double? width]) => Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(theme.radius.rXs),
      ),
    );
    return ExcludeSemantics(
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(spacing.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.spacingM,
            children: [
              block(_galleryHeight),
              block(spacing.spacingXl, spacing.spacing4xl * 4),
              block(spacing.spacingM, spacing.spacing4xl * 3),
              block(spacing.spacingM),
              block(spacing.spacingM),
            ],
          ),
        ),
      ),
    );
  }
}
