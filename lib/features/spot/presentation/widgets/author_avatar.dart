import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spotshare/core/theme/app_theme.dart';

class AuthorAvatar extends StatelessWidget {
  const AuthorAvatar({super.key, required this.avatarUrl, required this.size});

  final String? avatarUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appTheme.colors;
    final url = avatarUrl;
    final fallback = Icon(
      Icons.person,
      size: size * 0.6,
      color: colors.foregroundMuted,
    );
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: ColoredBox(
          color: colors.surfaceMuted,
          child: url == null
              ? fallback
              : CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  memCacheWidth: (size * dpr).round(),
                  placeholder: (_, _) => fallback,
                  errorWidget: (_, _, _) => fallback,
                ),
        ),
      ),
    );
  }
}
