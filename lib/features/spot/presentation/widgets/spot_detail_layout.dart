import 'package:flutter/material.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/spot/domain/entities/spot.dart';

class SpotDetailLayout extends StatelessWidget {
  const SpotDetailLayout({super.key, required this.spot});

  final Spot spot;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(theme.spacing.spacingM),
            sliver: SliverToBoxAdapter(
              child: Text(spot.title, style: theme.textStyles.h2),
            ),
          ),
        ],
      ),
    );
  }
}
