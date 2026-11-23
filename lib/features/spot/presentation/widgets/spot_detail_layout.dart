import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/spot/domain/entities/spot.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_description.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_gallery.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_header.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_tags.dart';

class SpotDetailLayout extends StatelessWidget {
  const SpotDetailLayout({super.key, required this.spot});

  static const _galleryHeight = 320.0;

  final Spot spot;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final gap = SizedBox(height: theme.spacing.spacingM);
    return SafeArea(
      top: false,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: _galleryHeight,
            backgroundColor: theme.colors.inverse,
            leading: Padding(
              padding: EdgeInsets.all(theme.spacing.spacingXs),
              child: BackButton(
                style: IconButton.styleFrom(
                  backgroundColor: theme.colors.mediaButton,
                  foregroundColor: theme.colors.onMedia,
                ),
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRoutes.home),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: SpotGallery(spot: spot, height: _galleryHeight),
            ),
          ),
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
