import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/spot/domain/entities/spot.dart';
import 'package:spotshare/features/spot/presentation/hero_tags.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_media_thumbnail.dart';
import 'package:spotshare/i18n/strings.g.dart';

class SpotGallery extends StatefulWidget {
  const SpotGallery({super.key, required this.spot, required this.height});

  final Spot spot;
  final double height;

  @override
  State<SpotGallery> createState() => _SpotGalleryState();
}

class _SpotGalleryState extends State<SpotGallery> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final media = widget.spot.media;
    if (media.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: ColoredBox(
          color: theme.colors.surfaceMuted,
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: theme.spacing.spacing4xl,
              color: theme.colors.foregroundMuted,
            ),
          ),
        ),
      );
    }
    final current = _current.clamp(0, media.length - 1);
    final width = MediaQuery.sizeOf(context).width;
    return SizedBox(
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: media.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => context.push(AppRoutes.spotMedia(widget.spot.id, i)),
              child: Hero(
                tag: spotMediaHeroTag(widget.spot.id, i),
                child: SpotMediaThumbnail(media: media[i], width: width),
              ),
            ),
          ),
          Positioned(
            right: theme.spacing.spacingM,
            bottom: theme.spacing.spacingM,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.mediaLabel,
                borderRadius: BorderRadius.circular(theme.radius.full),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing.spacingS,
                  vertical: theme.spacing.spacing2xs,
                ),
                child: Text(
                  context.t.spot.media.position(
                    current: current + 1,
                    total: media.length,
                  ),
                  style: theme.textStyles.b3.copyWith(
                    color: theme.colors.onMedia,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
