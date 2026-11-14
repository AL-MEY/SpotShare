import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:spotshare/features/auth/presentation/pages/login_page.dart';
import 'package:spotshare/features/auth/presentation/pages/welcome_page.dart';
import 'package:spotshare/home_page.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/pump_app.dart';

Future<void> _openLogin(WidgetTester tester, FakeAuthRepository auth) async {
  final container = await pumpApp(tester, auth: auth);
  container.read(routerProvider).go(AppRoutes.login);
  await tester.pumpAndSettle();
}

Future<void> _fillAndSubmit(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).at(0), 'a@spotshare.app');
  await tester.enterText(find.byType(TextFormField).at(1), 'secret');
  await tester.tap(find.text('Se connecter'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('refuse un formulaire vide sans appeler le repository', (
    tester,
  ) async {
    await _openLogin(tester, FakeAuthRepository());

    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.text('Saisis un e-mail valide.'), findsOneWidget);
    expect(find.text('Saisis ton mot de passe.'), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('la connexion par e-mail mène à l’accueil', (tester) async {
    await _openLogin(tester, FakeAuthRepository());

    await _fillAndSubmit(tester);

    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('affiche la bottom sheet quand les identifiants sont faux', (
    tester,
  ) async {
    final auth = FakeAuthRepository()
      ..failure = const InvalidCredentialsFailure();
    await _openLogin(tester, auth);

    await _fillAndSubmit(tester);

    expect(find.text('Identifiants incorrects'), findsOneWidget);
  });

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
    final auth = FakeAuthRepository()..failure = const NetworkFailure();
    await _openLogin(tester, auth);

    await tester.tap(find.text('Continuer avec Google'));
    await tester.pumpAndSettle();

    expect(find.text('Pas de connexion'), findsOneWidget);
  });

  testWidgets('ouvre le mot de passe oublié', (tester) async {
    await _openLogin(tester, FakeAuthRepository());

    await tester.tap(find.text('Mot de passe oublié ?'));
    await tester.pumpAndSettle();

    expect(find.byType(ForgotPasswordPage), findsOneWidget);
  });
}
