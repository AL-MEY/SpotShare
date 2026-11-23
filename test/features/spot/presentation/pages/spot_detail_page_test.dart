import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/core/router/not_found_page.dart';
import 'package:spotshare/features/spot/presentation/pages/spot_detail_page.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_detail_skeleton.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_comment_repository.dart';
import '../../../../helpers/fake_rating_repository.dart';
import '../../../../helpers/fake_spot_author_repository.dart';
import '../../../../helpers/fake_spot_repository.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/spot_fixtures.dart';

void main() {
  late FakeSpotRepository spots;

  Future<ProviderContainer> pumpSpotApp(
    WidgetTester tester, {
    Failure? failure,
  }) async {
    spots = FakeSpotRepository(spot: buildSpot())..failure = failure;
    addTearDown(spots.dispose);
    final container = await pumpApp(
      tester,
      auth: FakeAuthRepository(FakeAuthRepository.user),
      overrides: [
        spotRepositoryProvider.overrideWithValue(spots),
        ratingRepositoryProvider.overrideWithValue(FakeRatingRepository()),
        commentRepositoryProvider.overrideWithValue(FakeCommentRepository()),
        spotAuthorRepositoryProvider.overrideWithValue(
          FakeSpotAuthorRepository(),
        ),
      ],
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('affiche le squelette pendant le chargement', (tester) async {
    spots = FakeSpotRepository();
    addTearDown(spots.dispose);
    final container = await pumpApp(
      tester,
      auth: FakeAuthRepository(FakeAuthRepository.user),
      overrides: [spotRepositoryProvider.overrideWithValue(spots)],
    );
    await tester.pumpAndSettle();
    container.read(routerProvider).go(AppRoutes.spotDetail(spotId));
    await tester.pump();

    expect(find.byType(SpotDetailPage), findsOneWidget);
    expect(find.byType(SpotDetailSkeleton), findsOneWidget);
  });

  testWidgets('affiche le titre du spot une fois chargé', (tester) async {
    final container = await pumpSpotApp(tester);
    container.read(routerProvider).go(AppRoutes.spotDetail(spotId));
    await tester.pumpAndSettle();

    expect(find.text('Café du coin'), findsOneWidget);
    expect(find.byType(SpotDetailSkeleton), findsNothing);
  });

  testWidgets('affiche l’erreur et réessaie au tap sur Réessayer', (
    tester,
  ) async {
    final container = await pumpSpotApp(
      tester,
      failure: const NetworkFailure(),
    );
    container.read(routerProvider).go(AppRoutes.spotDetail(spotId));
    await tester.pumpAndSettle();

    expect(find.text('Pas de connexion'), findsOneWidget);

    spots.failure = null;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('Café du coin'), findsOneWidget);
  });

  testWidgets(
    'bascule sur Introuvable quand le spot est supprimé pendant l’affichage',
    (tester) async {
      final container = await pumpSpotApp(tester);
      container.read(routerProvider).go(AppRoutes.spotDetail(spotId));
      await tester.pumpAndSettle();
      expect(find.text('Café du coin'), findsOneWidget);

      spots.emitFailure(const NotFoundFailure());
      await tester.pumpAndSettle();

      expect(find.text('Introuvable'), findsOneWidget);
      expect(find.text('Café du coin'), findsNothing);
    },
  );

  testWidgets('une route /spots/ inconnue affiche la page introuvable', (
    tester,
  ) async {
    final container = await pumpSpotApp(tester);
    container.read(routerProvider).go('/spots/$spotId/inconnu');
    await tester.pumpAndSettle();

    expect(find.byType(NotFoundPage), findsOneWidget);
  });
}
