import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/features/auth/presentation/pages/sign_up_page.dart';
import 'package:spotshare/home_page.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/pump_app.dart';

Future<void> _signUp(
  WidgetTester tester,
  FakeAuthRepository auth, {
  String password = 'secret',
}) async {
  final container = await pumpApp(tester, auth: auth);
  container.read(routerProvider).go(AppRoutes.signUp);
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).at(0), 'a@spotshare.app');
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.tap(find.text('Créer mon compte'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('refuse un mot de passe de moins de 6 caractères', (
    tester,
  ) async {
    await _signUp(tester, FakeAuthRepository(), password: '12345');

    expect(find.text('Au moins 6 caractères.'), findsOneWidget);
    expect(find.byType(SignUpPage), findsOneWidget);
  });

  testWidgets('l’inscription mène à l’accueil', (tester) async {
    await _signUp(tester, FakeAuthRepository());

    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('affiche la bottom sheet quand l’e-mail est déjà utilisé', (
    tester,
  ) async {
    final auth = FakeAuthRepository()
      ..failure = const EmailAlreadyUsedFailure();

    await _signUp(tester, auth);

    expect(find.text('E-mail déjà utilisé'), findsOneWidget);
  });

  testWidgets('la connexion Google depuis l’inscription mène à l’accueil', (
    tester,
  ) async {
    final container = await pumpApp(tester, auth: FakeAuthRepository());
    container.read(routerProvider).go(AppRoutes.signUp);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continuer avec Google'));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });
}
