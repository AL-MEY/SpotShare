import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/app.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/i18n/strings.g.dart';

Future<void> _pumpApp(WidgetTester tester, AppLocale locale) async {
  await tester.runAsync(() => LocaleSettings.setLocale(locale));
  await tester.pumpWidget(
    ProviderScope(child: TranslationProvider(child: const SpotShareApp())),
  );
}

void main() {
  testWidgets('affiche la page d’accueil en français', (tester) async {
    await _pumpApp(tester, AppLocale.fr);

    expect(find.text('Bienvenue sur SpotShare'), findsOneWidget);
  });

  testWidgets('affiche la page d’accueil en anglais', (tester) async {
    await _pumpApp(tester, AppLocale.en);

    expect(find.text('Welcome to SpotShare'), findsOneWidget);
  });

  testWidgets('expose AppTheme via context.appTheme', (tester) async {
    await _pumpApp(tester, AppLocale.fr);

    final context = tester.element(find.byType(Scaffold));
    expect(context.appTheme, isA<AppTheme>());
  });
}
