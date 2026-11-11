import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/app.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/i18n/strings.g.dart';

void main() {
  testWidgets('affiche la page introuvable puis revient à l’accueil', (
    tester,
  ) async {
    await tester.runAsync(() => LocaleSettings.setLocale(AppLocale.fr));
    await tester.pumpWidget(
      ProviderScope(child: TranslationProvider(child: const SpotShareApp())),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SpotShareApp)),
    );

    container.read(routerProvider).go('/route-inconnue');
    await tester.pumpAndSettle();

    expect(find.text('Contenu introuvable.'), findsOneWidget);

    await tester.tap(find.text('Retour à l’accueil'));
    await tester.pumpAndSettle();

    expect(find.text('Bienvenue sur SpotShare'), findsOneWidget);
  });
}
