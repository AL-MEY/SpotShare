import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/i18n/strings.g.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('affiche l’écran de bienvenue en français', (tester) async {
    await pumpApp(tester);

    expect(find.text('Partage tes meilleurs spots'), findsOneWidget);
  });

  testWidgets('affiche l’écran de bienvenue en anglais', (tester) async {
    await pumpApp(tester, locale: AppLocale.en);

    expect(find.text('Share your best spots'), findsOneWidget);
  });

  testWidgets('expose AppTheme via context.appTheme', (tester) async {
    await pumpApp(tester);

    final context = tester.element(find.byType(Scaffold));
    expect(context.appTheme, isA<AppTheme>());
  });
}
