import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/features/auth/presentation/pages/welcome_page.dart';
import 'package:spotshare/home_page.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/pump_app.dart';

void main() {
  testWidgets('redirige un visiteur vers l’écran de bienvenue', (tester) async {
    final container = await pumpApp(tester);

    container.read(routerProvider).go(AppRoutes.home);
    await tester.pumpAndSettle();

    expect(find.byType(WelcomePage), findsOneWidget);
  });

  testWidgets('suit la connexion puis la déconnexion', (tester) async {
    final auth = FakeAuthRepository();
    await pumpApp(tester, auth: auth);

    auth.emit(FakeAuthRepository.user);
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);

    auth.emit(null);
    await tester.pumpAndSettle();
    expect(find.byType(WelcomePage), findsOneWidget);
  });

  testWidgets('affiche la page introuvable puis revient à l’accueil', (
    tester,
  ) async {
    final container = await pumpApp(
      tester,
      auth: FakeAuthRepository(FakeAuthRepository.user),
    );

    container.read(routerProvider).go('/route-inconnue');
    await tester.pumpAndSettle();

    expect(find.text('Contenu introuvable.'), findsOneWidget);

    await tester.tap(find.text('Retour à l’accueil'));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });
}
