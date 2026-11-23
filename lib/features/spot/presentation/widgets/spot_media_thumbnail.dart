import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/spot/domain/entities/spot_media.dart';

class SpotMediaThumbnail extends StatelessWidget {
  const SpotMediaThumbnail({
    super.key,
    required this.media,
    required this.width,
  });

  final SpotMedia media;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final fallback = ColoredBox(
      color: theme.colors.surfaceMuted,
      child: Center(
        child: Icon(Icons.image_outlined, color: theme.colors.foregroundMuted),
      ),
    );
    final image = CachedNetworkImage(
      imageUrl: media.previewUrl,
      fit: BoxFit.cover,
      width: width,
      memCacheWidth: (width * dpr).round(),
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => fallback,
    );
    return switch (media) {
      SpotPhoto() => image,
      SpotVideo(:final duration) => Stack(
        fit: StackFit.expand,
        children: [
          image,
          Center(
            child: Icon(
              Icons.play_circle_fill,
              size: theme.spacing.spacing4xl,
              color: theme.colors.onMedia,
            ),
          ),
          Positioned(
            right: theme.spacing.spacingS,
            bottom: theme.spacing.spacingS,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.mediaLabel,
                borderRadius: BorderRadius.circular(theme.radius.rXs),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing.spacingXs,
                  vertical: theme.spacing.spacing3xs,
                ),
                child: Text(
                  formatVideoDuration(duration),
                  style: theme.textStyles.b3.copyWith(
                    color: theme.colors.onMedia,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    };
  }
}

String formatVideoDuration(Duration d) =>
    '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
