import 'package:flutter/material.dart';
import 'package:spotshare/core/theme/app_theme.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({
    required this.value,
    this.onChanged,
    this.size,
    this.semanticLabel,
    super.key,
  });

  static const _starCount = 5;

  final double value;
  final ValueChanged<int>? onChanged;
  final double? size;
  final String Function(int)? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final iconSize = size ?? theme.spacing.spacingL;
    final color = theme.colors.accent;
    final onChanged = this.onChanged;

    final stars = [
      for (var n = 1; n <= _starCount; n++)
        if (onChanged != null)
          IconButton(
            onPressed: () => onChanged(n),
            tooltip: semanticLabel?.call(n),
            iconSize: iconSize,
            color: color,
            icon: Icon(n <= value ? Icons.star : Icons.star_border),
          )
        else
          Icon(_readOnlyIcon(n), size: iconSize, color: color),
    ];
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  // Arrondi à la demi-étoile la plus proche.
  IconData _readOnlyIcon(int n) {
    final rounded = (value * 2).round() / 2;
    if (rounded >= n) return Icons.star;
    if (rounded >= n - 0.5) return Icons.star_half;
    return Icons.star_border;
  }
}
