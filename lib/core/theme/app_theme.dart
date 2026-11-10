import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'app_theme.tailor.dart';

@TailorMixin(themeGetter: ThemeGetter.onBuildContext)
class AppTheme extends ThemeExtension<AppTheme> with _$AppThemeTailorMixin {
  const AppTheme({
    required this.colors,
    required this.spacing,
    required this.radius,
  });

  @override
  final AppColorsTheme colors;
  @override
  final AppSpacingTheme spacing;
  @override
  final AppRadiusTheme radius;
}

@TailorMixin(themeGetter: ThemeGetter.none)
class AppColorsTheme extends ThemeExtension<AppColorsTheme>
    with _$AppColorsThemeTailorMixin {
  const AppColorsTheme({
    required this.success,
    required this.warning,
    required this.rating,
  });

  @override
  final Color success;
  @override
  final Color warning;

  @override
  final Color rating;
}

@TailorMixin(themeGetter: ThemeGetter.none)
class AppSpacingTheme extends ThemeExtension<AppSpacingTheme>
    with _$AppSpacingThemeTailorMixin {
  const AppSpacingTheme({
    required this.xs,
    required this.s,
    required this.m,
    required this.l,
    required this.xl,
  });

  @override
  final double xs;
  @override
  final double s;
  @override
  final double m;
  @override
  final double l;
  @override
  final double xl;
}

@TailorMixin(themeGetter: ThemeGetter.none)
class AppRadiusTheme extends ThemeExtension<AppRadiusTheme>
    with _$AppRadiusThemeTailorMixin {
  const AppRadiusTheme({
    required this.s,
    required this.m,
    required this.l,
    required this.full,
  });

  @override
  final double s;
  @override
  final double m;
  @override
  final double l;
  @override
  final double full;
}
