import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'app_theme.tailor.dart';

@TailorMixin(themeGetter: ThemeGetter.onBuildContext)
class AppTheme extends ThemeExtension<AppTheme> with _$AppThemeTailorMixin {
  const AppTheme({
    required this.colors,
    required this.textStyles,
    required this.spacing,
    required this.radius,
    required this.stroke,
    required this.shadows,
    required this.opacity,
  });

  @override
  final AppColorsTheme colors;
  @override
  final AppTextStylesTheme textStyles;
  @override
  final AppSpacingTheme spacing;
  @override
  final AppRadiusTheme radius;
  @override
  final AppStrokeTheme stroke;
  @override
  final AppShadowsTheme shadows;
  @override
  final AppOpacityTheme opacity;
}

@TailorMixin(themeGetter: ThemeGetter.none)
class AppColorsTheme extends ThemeExtension<AppColorsTheme>
    with _$AppColorsThemeTailorMixin {
  const AppColorsTheme({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.foreground,
    required this.foregroundMuted,
    required this.border,
    required this.borderSubtle,
    required this.action,
    required this.onAction,
    required this.accent,
    required this.onAccent,
    required this.error,
    required this.focus,
    required this.inverse,
    required this.onInverse,
    required this.scrim,
    required this.onMedia,
    required this.mediaButton,
    required this.mediaLabel,
    required this.mapLand,
    required this.mapRoad,
    required this.mapPark,
  });

  @override
  final Color background;

  @override
  final Color surface;

  @override
  final Color surfaceMuted;

  @override
  final Color foreground;

  @override
  final Color foregroundMuted;

  @override
  final Color border;

  @override
  final Color borderSubtle;

  @override
  final Color action;

  @override
  final Color onAction;

  @override
  final Color accent;

  @override
  final Color onAccent;

  @override
  final Color error;

  @override
  final Color focus;

  @override
  final Color inverse;

  @override
  final Color onInverse;

  @override
  final Color scrim;

  @override
  final Color onMedia;

  @override
  final Color mediaButton;

  @override
  final Color mediaLabel;

  @override
  final Color mapLand;

  @override
  final Color mapRoad;

  @override
  final Color mapPark;
}

@TailorMixin(themeGetter: ThemeGetter.none)
class AppTextStylesTheme extends ThemeExtension<AppTextStylesTheme>
    with _$AppTextStylesThemeTailorMixin {
  const AppTextStylesTheme({
    required this.h1,
    required this.h2,
    required this.h3,
    required this.b1,
    required this.b2,
    required this.b3,
    required this.l1,
  });

  @override
  final TextStyle h1;

  @override
  final TextStyle h2;

  @override
  final TextStyle h3;

  @override
  final TextStyle b1;

  @override
  final TextStyle b2;

  @override
  final TextStyle b3;

  @override
  final TextStyle l1;
}

@TailorMixin(themeGetter: ThemeGetter.none)
class AppSpacingTheme extends ThemeExtension<AppSpacingTheme>
    with _$AppSpacingThemeTailorMixin {
  const AppSpacingTheme({
    required this.spacing3xs,
    required this.spacing2xs,
    required this.spacingXs,
    required this.spacingS,
    required this.spacingM,
    required this.spacingL,
    required this.spacingXl,
    required this.spacing2xl,
    required this.spacing3xl,
    required this.spacing4xl,
  });

  @override
  final double spacing3xs;
  @override
  final double spacing2xs;
  @override
  final double spacingXs;
  @override
  final double spacingS;

  @override
  final double spacingM;
  @override
  final double spacingL;

  @override
  final double spacingXl;
  @override
  final double spacing2xl;
  @override
  final double spacing3xl;

  @override
  final double spacing4xl;
}

@TailorMixin(themeGetter: ThemeGetter.none)
class AppRadiusTheme extends ThemeExtension<AppRadiusTheme>
    with _$AppRadiusThemeTailorMixin {
  const AppRadiusTheme({
    required this.none,
    required this.rXs,
    required this.rS,
    required this.rM,
    required this.full,
  });

  @override
  final double none;

  @override
  final double rXs;

  @override
  final double rS;

  @override
  final double rM;

  @override
  final double full;
}

@TailorMixin(themeGetter: ThemeGetter.none)
class AppStrokeTheme extends ThemeExtension<AppStrokeTheme>
    with _$AppStrokeThemeTailorMixin {
  const AppStrokeTheme({
    required this.strokeS,
    required this.strokeM,
    required this.strokeL,
  });

  @override
  final double strokeS;

  @override
  final double strokeM;

  @override
  final double strokeL;
}

@TailorMixin(themeGetter: ThemeGetter.none)
class AppShadowsTheme extends ThemeExtension<AppShadowsTheme>
    with _$AppShadowsThemeTailorMixin {
  const AppShadowsTheme({required this.float, required this.focusRing});

  @override
  final List<BoxShadow> float;

  @override
  final List<BoxShadow> focusRing;
}

@TailorMixin(themeGetter: ThemeGetter.none)
class AppOpacityTheme extends ThemeExtension<AppOpacityTheme>
    with _$AppOpacityThemeTailorMixin {
  const AppOpacityTheme({
    required this.stateHover,
    required this.stateFocus,
    required this.statePressed,
    required this.stateDragged,
    required this.disabledContent,
    required this.disabledContainer,
  });

  @override
  final double stateHover;
  @override
  final double stateFocus;
  @override
  final double statePressed;

  @override
  final double stateDragged;

  @override
  final double disabledContent;

  @override
  final double disabledContainer;
}
