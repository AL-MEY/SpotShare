import 'package:flutter/material.dart';
import 'package:spotshare/core/theme/app_theme.dart';

const _seedColor = Color(0xFF0F766E);

const _spacing = AppSpacingTheme(xs: 4, s: 8, m: 16, l: 24, xl: 32);

const _radius = AppRadiusTheme(s: 8, m: 16, l: 24, full: 999);

const _lightColors = AppColorsTheme(
  success: Color(0xFF1B873F),
  warning: Color(0xFFB26A00),
  rating: Color(0xFFF5A623),
);

const _darkColors = AppColorsTheme(
  success: Color(0xFF6FD08C),
  warning: Color(0xFFFFB74D),
  rating: Color(0xFFFFC857),
);

const _lightAppTheme = AppTheme(
  colors: _lightColors,
  spacing: _spacing,
  radius: _radius,
);

const _darkAppTheme = AppTheme(
  colors: _darkColors,
  spacing: _spacing,
  radius: _radius,
);

final lightTheme = _buildTheme(Brightness.light, _lightAppTheme);
final darkTheme = _buildTheme(Brightness.dark, _darkAppTheme);

ThemeData _buildTheme(Brightness brightness, AppTheme appTheme) => ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: brightness,
  ),
  extensions: [appTheme],
);
