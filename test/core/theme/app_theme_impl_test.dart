import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/core/theme/app_theme_impl.dart';

void main() {
  for (final (name, theme) in [('clair', lightTheme), ('sombre', darkTheme)]) {
    group('thème $name', () {
      final colors = theme.extension<AppTheme>()!.colors;
      final scheme = theme.colorScheme;

      test('les rôles Material 3 suivent les alias du design system', () {
        expect(scheme.primary, colors.action);
        expect(scheme.onPrimary, colors.onAction);
        expect(scheme.tertiary, colors.accent);
        expect(scheme.surface, colors.background);
        expect(scheme.surfaceContainerLow, colors.surface);
        expect(scheme.surfaceContainerHigh, colors.surfaceMuted);
        expect(scheme.onSurface, colors.foreground);
        expect(scheme.outline, colors.border);
        expect(scheme.error, colors.error);
        expect(theme.scaffoldBackgroundColor, colors.background);
      });

      test('le texte par défaut utilise la couleur foreground', () {
        expect(theme.textTheme.bodyMedium?.color, colors.foreground);
      });
    });
  }

  test('le vermillon change de teinte entre clair et sombre', () {
    final light = lightTheme.extension<AppTheme>()!.colors.accent;
    final dark = darkTheme.extension<AppTheme>()!.colors.accent;

    expect(light, isNot(dark));
    expect(lightTheme.colorScheme.brightness, Brightness.light);
    expect(darkTheme.colorScheme.brightness, Brightness.dark);
  });
}
