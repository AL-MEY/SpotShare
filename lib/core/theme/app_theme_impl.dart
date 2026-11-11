import 'package:flutter/material.dart';
import 'package:spotshare/core/theme/app_theme.dart';

abstract final class _Palette {
  static const neutral100 = Color(0xFFFFFFFF);
  static const neutral200 = Color(0xFFF7F7F4);
  static const neutral300 = Color(0xFFEDEDEA);
  static const neutral400 = Color(0xFFE4E3E0);
  static const neutral500 = Color(0xFFA5A4A2);
  static const neutral600 = Color(0xFF7C7C79);
  static const neutral700 = Color(0xFF5E5E5B);
  static const neutral800 = Color(0xFF302F2D);
  static const neutral900 = Color(0xFF262523);
  static const neutral1000 = Color(0xFF1C1C1A);
  static const neutral1100 = Color(0xFF171614);
  static const neutral1200 = Color(0xFF121210);
  static const neutralAlpha30 = Color.fromRGBO(18, 18, 16, 0.3);
  static const neutralAlpha40 = Color.fromRGBO(18, 18, 16, 0.4);
  static const neutralAlpha60 = Color.fromRGBO(18, 18, 16, 0.6);
  static const brand100 = Color(0xFFFF7A57);
  static const brand200 = Color(0xFFCC3F1C);
  static const brand300 = Color(0xFF2A0A02);
  static const error100 = Color(0xFFFF8FA3);
  static const error200 = Color(0xFFA8182A);
}

const _lightColors = AppColorsTheme(
  background: _Palette.neutral100,
  surface: _Palette.neutral200,
  surfaceMuted: _Palette.neutral300,
  foreground: _Palette.neutral1100,
  foregroundMuted: _Palette.neutral700,
  border: _Palette.neutral600,
  borderSubtle: _Palette.neutral400,
  action: _Palette.neutral1100,
  onAction: _Palette.neutral100,
  accent: _Palette.brand200,
  onAccent: _Palette.neutral100,
  error: _Palette.error200,
  focus: _Palette.neutral1100,
  inverse: _Palette.neutral1000,
  onInverse: _Palette.neutral200,
  scrim: _Palette.neutralAlpha60,
  onMedia: _Palette.neutral100,
  mediaButton: _Palette.neutralAlpha30,
  mediaLabel: _Palette.neutralAlpha40,
  mapLand: _Palette.neutral200,
  mapRoad: _Palette.neutral100,
  mapPark: _Palette.neutral300,
);

const _darkColors = AppColorsTheme(
  background: _Palette.neutral1200,
  surface: _Palette.neutral1000,
  surfaceMuted: _Palette.neutral900,
  foreground: _Palette.neutral200,
  foregroundMuted: _Palette.neutral500,
  border: _Palette.neutral600,
  borderSubtle: _Palette.neutral800,
  action: _Palette.neutral200,
  onAction: _Palette.neutral1200,
  accent: _Palette.brand100,
  onAccent: _Palette.brand300,
  error: _Palette.error100,
  focus: _Palette.neutral200,
  inverse: _Palette.neutral300,
  onInverse: _Palette.neutral1000,
  scrim: _Palette.neutralAlpha60,
  onMedia: _Palette.neutral100,
  mediaButton: _Palette.neutralAlpha30,
  mediaLabel: _Palette.neutralAlpha40,
  mapLand: _Palette.neutral1100,
  mapRoad: _Palette.neutral800,
  mapPark: _Palette.neutral1000,
);

const _fontFamily = 'InstrumentSans';
const _tabularFigures = [FontFeature.tabularFigures()];

const _textStyles = AppTextStylesTheme(
  h1: TextStyle(
    fontFamily: _fontFamily,
    fontFeatures: _tabularFigures,
    fontSize: 32,
    height: 38 / 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.64,
  ),
  h2: TextStyle(
    fontFamily: _fontFamily,
    fontFeatures: _tabularFigures,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.22,
  ),
  h3: TextStyle(
    fontFamily: _fontFamily,
    fontFeatures: _tabularFigures,
    fontSize: 17,
    height: 22 / 17,
    fontWeight: FontWeight.w600,
  ),
  b1: TextStyle(
    fontFamily: _fontFamily,
    fontFeatures: _tabularFigures,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  ),
  b2: TextStyle(
    fontFamily: _fontFamily,
    fontFeatures: _tabularFigures,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  ),
  b3: TextStyle(
    fontFamily: _fontFamily,
    fontFeatures: _tabularFigures,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
  ),
  l1: TextStyle(
    fontFamily: _fontFamily,
    fontFeatures: _tabularFigures,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
  ),
);

const _spacing = AppSpacingTheme(
  spacing3xs: 2,
  spacing2xs: 4,
  spacingXs: 8,
  spacingS: 12,
  spacingM: 16,
  spacingL: 20,
  spacingXl: 24,
  spacing2xl: 32,
  spacing3xl: 40,
  spacing4xl: 48,
);

const _radius = AppRadiusTheme(none: 0, rXs: 8, rS: 12, rM: 20, full: 999);

const _stroke = AppStrokeTheme(strokeS: 1, strokeM: 2, strokeL: 3);

const _opacity = AppOpacityTheme(
  stateHover: 0.08,
  stateFocus: 0.10,
  statePressed: 0.10,
  stateDragged: 0.16,
  disabledContent: 0.38,
  disabledContainer: 0.12,
);

const _lightShadows = AppShadowsTheme(
  float: [
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: Color(0x29000000),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -6,
    ),
  ],
  focusRing: [
    BoxShadow(color: _Palette.neutral1100, spreadRadius: 4),
    BoxShadow(color: _Palette.neutral100, spreadRadius: 2),
  ],
);

const _darkShadows = AppShadowsTheme(
  float: [
    BoxShadow(color: Color(0x80000000), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: Color(0xB3000000),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -6,
    ),
  ],
  focusRing: [
    BoxShadow(color: _Palette.neutral200, spreadRadius: 4),
    BoxShadow(color: _Palette.neutral1200, spreadRadius: 2),
  ],
);

const _lightAppTheme = AppTheme(
  colors: _lightColors,
  textStyles: _textStyles,
  spacing: _spacing,
  radius: _radius,
  stroke: _stroke,
  shadows: _lightShadows,
  opacity: _opacity,
);

const _darkAppTheme = AppTheme(
  colors: _darkColors,
  textStyles: _textStyles,
  spacing: _spacing,
  radius: _radius,
  stroke: _stroke,
  shadows: _darkShadows,
  opacity: _opacity,
);

final lightTheme = _buildTheme(Brightness.light, _lightAppTheme);
final darkTheme = _buildTheme(Brightness.dark, _darkAppTheme);

ThemeData _buildTheme(Brightness brightness, AppTheme appTheme) {
  final colorScheme = _colorScheme(brightness, appTheme.colors);
  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: appTheme.colors.background,
    fontFamily: _fontFamily,
    textTheme: _textTheme(appTheme.textStyles).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    extensions: [appTheme],
  );
}

ColorScheme _colorScheme(Brightness brightness, AppColorsTheme c) =>
    ColorScheme(
      brightness: brightness,
      primary: c.action,
      onPrimary: c.onAction,
      secondary: c.action,
      onSecondary: c.onAction,
      tertiary: c.accent,
      onTertiary: c.onAccent,
      error: c.error,
      onError: c.onAction,
      surface: c.background,
      onSurface: c.foreground,
      onSurfaceVariant: c.foregroundMuted,
      surfaceContainerLowest: c.background,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surface,
      surfaceContainerHigh: c.surfaceMuted,
      surfaceContainerHighest: c.surfaceMuted,
      outline: c.border,
      outlineVariant: c.borderSubtle,
      inverseSurface: c.inverse,
      onInverseSurface: c.onInverse,
    );

TextTheme _textTheme(AppTextStylesTheme s) => TextTheme(
  headlineLarge: s.h1,
  titleLarge: s.h2,
  titleMedium: s.h3,
  bodyLarge: s.b1,
  bodyMedium: s.b2,
  bodySmall: s.b3,
  labelLarge: s.l1,
);
