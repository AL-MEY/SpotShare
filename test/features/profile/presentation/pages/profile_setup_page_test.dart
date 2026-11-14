import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/features/auth/presentation/pages/welcome_page.dart';
import 'package:spotshare/features/profile/domain/entities/user_profile.dart';
import 'package:spotshare/features/profile/presentation/pages/profile_loading_page.dart';
import 'package:spotshare/features/profile/presentation/pages/profile_setup_page.dart';
import 'package:spotshare/home_page.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_profile_repository.dart';
import '../../../../helpers/pump_app.dart';

Future<FakeProfileRepository> _pumpNewUser(WidgetTester tester) async {
  final profile = FakeProfileRepository(null);
  await pumpApp(
    tester,
    auth: FakeAuthRepository(FakeAuthRepository.user),
    profile: profile,
  );
  await tester.pumpAndSettle();
  return profile;
}

Future<void> _fillAndSubmit(WidgetTester tester, String name) async {
  await tester.enterText(find.byType(TextFormField).at(0), name);
  await tester.enterText(find.byType(TextFormField).at(1), 'Cafés');
  await tester.tap(find.text('C’est parti'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('un utilisateur sans profil arrive sur la création du profil', (
    tester,
  ) async {
    await _pumpNewUser(tester);

    expect(find.byType(ProfileSetupPage), findsOneWidget);
  });

  testWidgets('refuse un nom de moins de 2 caractères', (tester) async {
    final profile = await _pumpNewUser(tester);

    await _fillAndSubmit(tester, ' C ');

    expect(find.text('Au moins 2 caractères.'), findsOneWidget);
    expect(profile.saved, isNull);
  });

  testWidgets('enregistre le profil puis mène à l’accueil', (tester) async {
    final profile = await _pumpNewUser(tester);

    await _fillAndSubmit(tester, 'Camille');

    expect(
      profile.saved,
      const UserProfile(id: 'uid', displayName: 'Camille', bio: 'Cafés'),
    );
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('affiche la bottom sheet si l’enregistrement échoue', (
    tester,
  ) async {
    final profile = await _pumpNewUser(tester);
    profile.failure = const NetworkFailure();

    await _fillAndSubmit(tester, 'Camille');

    expect(find.text('Pas de connexion'), findsOneWidget);
    expect(find.byType(ProfileSetupPage), findsOneWidget);
  });

  testWidgets('permet de se déconnecter', (tester) async {
    await _pumpNewUser(tester);

    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomePage), findsOneWidget);
  });

  testWidgets('affiche l’erreur de chargement du profil avec Réessayer', (
    tester,
  ) async {
    await pumpApp(
      tester,
      auth: FakeAuthRepository(FakeAuthRepository.user),
      profile: FakeProfileRepository()..failure = const NetworkFailure(),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ProfileLoadingPage), findsOneWidget);
    expect(find.text('Pas de connexion'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
  });
}
