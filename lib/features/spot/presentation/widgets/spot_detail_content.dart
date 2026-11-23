import 'package:flutter/material.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/spot/domain/entities/spot.dart';
import 'package:spotshare/features/spot/presentation/widgets/comment_composer.dart';
import 'package:spotshare/features/spot/presentation/widgets/comment_list.dart';
import 'package:spotshare/features/spot/presentation/widgets/comments_title.dart';
import 'package:spotshare/features/spot/presentation/widgets/my_rating_stars.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_description.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_header.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_tags.dart';

// Sections sous la galerie, partagées par les layouts empilé et côte à côte.
class SpotDetailContent extends StatelessWidget {
  const SpotDetailContent({super.key, required this.spot});

  final Spot spot;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final gap = SizedBox(height: theme.spacing.spacingM);
    return SliverMainAxisGroup(
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
              gap,
              MyRatingStars(spot: spot),
              gap,
              CommentsTitle(spotId: spot.id),
              gap,
              CommentComposer(spotId: spot.id),
              gap,
            ],
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            theme.spacing.spacingM,
            0,
            theme.spacing.spacingM,
            theme.spacing.spacingL,
          ),
          sliver: CommentList(spotId: spot.id),
        ),
      ],
    );
  }
}
