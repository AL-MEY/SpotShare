import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/features/auth/presentation/pages/welcome_page.dart';
import 'package:spotshare/features/profile/presentation/pages/profile_loading_page.dart';
import 'package:spotshare/home_page.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_profile_repository.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late FakeProfileRepository profile;

  Future<void> pumpWithLoadError(WidgetTester tester) async {
    profile = FakeProfileRepository()..failure = const NetworkFailure();
    await pumpApp(
      tester,
      auth: FakeAuthRepository(FakeAuthRepository.user),
      profile: profile,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('affiche l’erreur de chargement du profil', (tester) async {
    await pumpWithLoadError(tester);

    expect(find.byType(ProfileLoadingPage), findsOneWidget);
    expect(find.text('Pas de connexion'), findsOneWidget);
  });

  testWidgets('Réessayer recharge le profil et mène à l’accueil', (
    tester,
  ) async {
    await pumpWithLoadError(tester);
    profile.failure = null;

    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('permet de se déconnecter quand le profil ne charge pas', (
    tester,
  ) async {
    await pumpWithLoadError(tester);

    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomePage), findsOneWidget);
  });
}
