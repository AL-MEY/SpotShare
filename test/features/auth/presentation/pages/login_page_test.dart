import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/features/auth/presentation/pages/welcome_page.dart';
import 'package:spotshare/home_page.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/pump_app.dart';

Future<void> _openLogin(WidgetTester tester, FakeAuthRepository auth) async {
  final container = await pumpApp(tester, auth: auth);
  container.read(routerProvider).go(AppRoutes.login);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('la connexion Google mène à l’accueil, la déconnexion en sort', (
    tester,
  ) async {
    await _openLogin(tester, FakeAuthRepository());

    await tester.tap(find.text('Continuer avec Google'));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);

    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomePage), findsOneWidget);
  });

  testWidgets('affiche la bottom sheet quand la connexion Google échoue', (
    tester,
  ) async {
    final auth = FakeAuthRepository()..googleFailure = const NetworkFailure();
    await _openLogin(tester, auth);

    await tester.tap(find.text('Continuer avec Google'));
    await tester.pumpAndSettle();

    expect(find.text('Pas de connexion'), findsOneWidget);
  });
}
