import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spotshare/core/theme/app_theme.dart';

class ZoomablePhoto extends StatelessWidget {
  const ZoomablePhoto({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = context.appTheme.colors;
    final icon = Center(
      child: Icon(Icons.image_outlined, color: colors.onInverse),
    );
    return InteractiveViewer(
      maxScale: 4,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        placeholder: (_, _) => icon,
        errorWidget: (_, _, _) => icon,
      ),
    );
  }
}
