import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/core/widgets/rating_stars.dart';
import 'package:spotshare/features/spot/domain/entities/spot.dart';
import 'package:spotshare/features/spot/presentation/hero_tags.dart';

class SpotListTile extends StatelessWidget {
  const SpotListTile({super.key, required this.spot});

  final Spot spot;

  static const _thumbnailSize = 72.0;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final coverUrl = spot.coverImageUrl;
    final placeholder = ColoredBox(
      color: theme.colors.surfaceMuted,
      child: Icon(Icons.image_outlined, color: theme.colors.foregroundMuted),
    );
    return ListTile(
      onTap: () => context.push(AppRoutes.spotDetail(spot.id), extra: spot),
      contentPadding: EdgeInsets.symmetric(horizontal: theme.spacing.spacingM),
      leading: Hero(
        tag: spotMediaHeroTag(spot.id, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(theme.radius.rXs),
          child: SizedBox.square(
            dimension: _thumbnailSize,
            child: coverUrl == null
                ? placeholder
                : CachedNetworkImage(
                    imageUrl: coverUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: (_thumbnailSize * dpr).round(),
                    placeholder: (_, _) => placeholder,
                    errorWidget: (_, _, _) => placeholder,
                  ),
          ),
        ),
      ),
      title: Text(
        spot.title,
        style: theme.textStyles.b1,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Align(
        alignment: Alignment.centerLeft,
        child: RatingStars(
          value: spot.averageRating,
          size: theme.spacing.spacingM,
        ),
      ),
    );
  }
}
