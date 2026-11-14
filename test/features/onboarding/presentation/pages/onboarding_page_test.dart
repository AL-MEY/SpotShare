import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/features/auth/presentation/pages/sign_up_page.dart';
import 'package:spotshare/features/onboarding/presentation/pages/onboarding_page.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('Continuer mène à la création de compte, retour à l’étape 1', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.byType(SignUpPage), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingPage), findsOneWidget);
  });
}
