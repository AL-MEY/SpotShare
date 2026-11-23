import 'package:flutter/material.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/spot/domain/entities/spot.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_description.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_header.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_tags.dart';

class SpotDetailLayout extends StatelessWidget {
  const SpotDetailLayout({super.key, required this.spot});

  final Spot spot;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final gap = SizedBox(height: theme.spacing.spacingM);
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(theme.spacing.spacingM),
            sliver: SliverList.list(
              children: [
                SpotHeader(spot: spot),
                if (spot.description.trim().isNotEmpty) ...[
                  gap,
                  SpotDescription(text: spot.description),
                ],
                if (spot.tags.isNotEmpty) ...[gap, SpotTags(tags: spot.tags)],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
