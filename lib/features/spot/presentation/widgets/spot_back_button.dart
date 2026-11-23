import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/core/theme/app_theme.dart';

class SpotBackButton extends StatelessWidget {
  const SpotBackButton({
    super.key,
    this.fallbackLocation = AppRoutes.home,
    this.onMedia = false,
    this.closeTooltip,
  });

  final String fallbackLocation;

  // Variante lisible sur une photo.
  final bool onMedia;

  // Si renseigné : icône de fermeture au lieu de la flèche retour.
  final String? closeTooltip;

  void _back(BuildContext context) =>
      context.canPop() ? context.pop() : context.go(fallbackLocation);

  @override
  Widget build(BuildContext context) {
    final colors = context.appTheme.colors;
    final style = onMedia
        ? IconButton.styleFrom(
            backgroundColor: colors.mediaButton,
            foregroundColor: colors.onMedia,
          )
        : null;
    final tooltip = closeTooltip;
    if (tooltip == null) {
      return BackButton(style: style, onPressed: () => _back(context));
    }
    return IconButton(
      tooltip: tooltip,
      icon: const Icon(Icons.close),
      style: style,
      onPressed: () => _back(context),
    );
  }
}
