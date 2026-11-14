import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:spotshare/features/auth/presentation/pages/login_page.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/pump_app.dart';

Future<void> _sendReset(WidgetTester tester, FakeAuthRepository auth) async {
  final container = await pumpApp(tester, auth: auth);
  final router = container.read(routerProvider)..go(AppRoutes.login);
  await tester.pumpAndSettle();
  unawaited(router.push(AppRoutes.forgotPassword));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField), ' a@spotshare.app ');
  await tester.tap(find.text('Envoyer le lien'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('envoie l’e-mail, confirme et revient à la connexion', (
    tester,
  ) async {
    final auth = FakeAuthRepository();

    await _sendReset(tester, auth);

    expect(auth.resetEmail, 'a@spotshare.app');
    expect(find.byType(LoginPage), findsOneWidget);
    expect(
      find.text(
        'Si un compte existe pour cet e-mail, un lien vient de t’être envoyé.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('reste sur la page et affiche l’erreur en cas d’échec', (
    tester,
  ) async {
    final auth = FakeAuthRepository()..failure = const NetworkFailure();

    await _sendReset(tester, auth);

    expect(find.byType(ForgotPasswordPage), findsOneWidget);
    expect(find.text('Pas de connexion'), findsOneWidget);
  });
}
