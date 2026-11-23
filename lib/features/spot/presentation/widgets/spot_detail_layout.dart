import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:spotshare/core/layout/breakpoints.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/spot/domain/entities/spot.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_back_button.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_detail_content_slivers.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_gallery.dart';

class SpotDetailLayout extends StatelessWidget {
  const SpotDetailLayout({super.key, required this.spot});

  static const _maxGalleryHeight = 320.0;
  static const _galleryHeightFraction = 0.45;

  final Spot spot;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = WindowSize.fromWidth(constraints.maxWidth);
        if (size == WindowSize.expanded) return _SideBySide(spot: spot);
        // Hauteur relative à l'écran pour ne pas écraser le contenu en paysage.
        final height = math.min(
          _maxGalleryHeight,
          MediaQuery.sizeOf(context).height * _galleryHeightFraction,
        );
        return _Stacked(spot: spot, galleryHeight: height);
      },
    );
  }
}

class _Stacked extends StatelessWidget {
  const _Stacked({required this.spot, required this.galleryHeight});

  final Spot spot;
  final double galleryHeight;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return SafeArea(
      top: false,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: galleryHeight,
            backgroundColor: theme.colors.inverse,
            leading: Padding(
              padding: EdgeInsets.all(theme.spacing.spacingXs),
              child: const SpotBackButton(onMedia: true),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: SpotGallery(spot: spot, height: galleryHeight),
            ),
          ),
          ...spotDetailContentSlivers(context, spot),
        ],
      ),
    );
  }
}

class _SideBySide extends StatelessWidget {
  const _SideBySide({required this.spot});

  final Spot spot;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Row(
      children: [
        Expanded(
          child: ColoredBox(
            color: theme.colors.inverse,
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) =>
                      SpotGallery(spot: spot, height: constraints.maxHeight),
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(theme.spacing.spacingXs),
                    child: const SpotBackButton(onMedia: true),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SafeArea(
            left: false,
            child: CustomScrollView(
              slivers: spotDetailContentSlivers(context, spot),
            ),
          ),
        ),
      ],
    );
  }
}
