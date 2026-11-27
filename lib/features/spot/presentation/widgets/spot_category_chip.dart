import 'package:flutter/material.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/spot/domain/entities/spot_category.dart';
import 'package:spotshare/i18n/strings.g.dart';

class SpotCategoryChip extends StatelessWidget {
  const SpotCategoryChip({super.key, required this.category});

  final SpotCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final t = context.t.spot.category;
    final (icon, label) = switch (category) {
      SpotCategory.cafe => (Icons.local_cafe, t.cafe),
      SpotCategory.viewpoint => (Icons.landscape, t.viewpoint),
      SpotCategory.streetArt => (Icons.palette, t.streetArt),
      SpotCategory.restaurant => (Icons.restaurant, t.restaurant),
      SpotCategory.park => (Icons.park, t.park),
      SpotCategory.other => (Icons.place, t.other),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.surfaceMuted,
        borderRadius: BorderRadius.circular(theme.radius.full),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.spacingS,
          vertical: theme.spacing.spacing2xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: theme.spacing.spacingM,
              color: theme.colors.foreground,
            ),
            SizedBox(width: theme.spacing.spacing2xs),
            Text(
              label,
              style: theme.textStyles.l1.copyWith(
                color: theme.colors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
