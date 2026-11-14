import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/theme/app_theme_impl.dart';
import 'package:spotshare/core/widgets/error_bottom_sheet.dart';
import 'package:spotshare/i18n/strings.g.dart';

Future<void> _openSheet(
  WidgetTester tester,
  Failure failure, {
  VoidCallback? onRetry,
}) async {
  await tester.runAsync(() => LocaleSettings.setLocale(AppLocale.fr));
  await tester.pumpWidget(
    TranslationProvider(
      child: MaterialApp(
        theme: lightTheme,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                showErrorBottomSheet(context, failure, onRetry: onRetry),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('affiche le titre et le message propres à la Failure', (
    tester,
  ) async {
    await _openSheet(tester, const NetworkFailure());

    expect(find.text('Pas de connexion'), findsOneWidget);
    expect(find.text('Connexion impossible. Vérifie ton réseau.'), findsOne);
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    expect(find.text('Réessayer'), findsNothing);
  });

  testWidgets('Réessayer ferme la sheet puis appelle onRetry', (tester) async {
    var retried = false;
    await _openSheet(
      tester,
      const UnknownFailure(),
      onRetry: () => retried = true,
    );

    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(retried, isTrue);
    expect(find.byType(ErrorBottomSheet), findsNothing);
  });

  testWidgets('Fermer ferme la sheet', (tester) async {
    await _openSheet(tester, const NotFoundFailure());

    await tester.tap(find.text('Fermer'));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorBottomSheet), findsNothing);
  });
}
