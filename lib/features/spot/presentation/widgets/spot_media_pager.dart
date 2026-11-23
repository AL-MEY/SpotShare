import 'package:flutter/material.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/spot/domain/entities/spot.dart';
import 'package:spotshare/features/spot/domain/entities/spot_media.dart';
import 'package:spotshare/features/spot/presentation/hero_tags.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_media_thumbnail.dart';
import 'package:spotshare/features/spot/presentation/widgets/zoomable_photo.dart';
import 'package:spotshare/i18n/strings.g.dart';

class SpotMediaPager extends StatefulWidget {
  const SpotMediaPager({
    super.key,
    required this.spot,
    required this.initialIndex,
  });

  final Spot spot;
  final int initialIndex;

  @override
  State<SpotMediaPager> createState() => _SpotMediaPagerState();
}

class _SpotMediaPagerState extends State<SpotMediaPager> {
  late final int _initial = widget.initialIndex.clamp(
    0,
    widget.spot.media.length - 1,
  );
  late final PageController _controller = PageController(initialPage: _initial);
  late int _current = _initial;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final media = widget.spot.media;
    final width = MediaQuery.sizeOf(context).width;
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: media.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (context, i) => Hero(
            tag: spotMediaHeroTag(widget.spot.id, i),
            child: switch (media[i]) {
              SpotPhoto(:final url) => ZoomablePhoto(url: url),
              final SpotVideo video => SpotMediaThumbnail(
                media: video,
                width: width,
              ),
            },
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: theme.spacing.spacingL,
          child: SafeArea(
            child: Center(
              child: Text(
                context.t.spot.media.position(
                  current: _current + 1,
                  total: media.length,
                ),
                style: theme.textStyles.b2.copyWith(
                  color: theme.colors.onInverse,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
