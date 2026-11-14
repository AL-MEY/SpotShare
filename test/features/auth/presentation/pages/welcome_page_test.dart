import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/features/auth/presentation/pages/login_page.dart';
import 'package:spotshare/features/onboarding/presentation/pages/onboarding_page.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('Commencer ouvre l’onboarding', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingPage), findsOneWidget);
  });

  testWidgets('J’ai déjà un compte ouvre la connexion', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('J’ai déjà un compte'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
