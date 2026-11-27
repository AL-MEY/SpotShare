import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/core/router/not_found_page.dart';
import 'package:spotshare/features/spot/presentation/pages/spot_detail_page.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_detail_layout.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_detail_skeleton.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_gallery.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_header.dart';

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
      spots: spots,
      overrides: [
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

  testWidgets('affiche le squelette pendant le chargement d’un lien direct', (
    tester,
  ) async {
    spots = FakeSpotRepository();
    addTearDown(spots.dispose);
    final container = await pumpApp(
      tester,
      auth: FakeAuthRepository(FakeAuthRepository.user),
      spots: spots,
    );
    await tester.pumpAndSettle();
    container.read(routerProvider).go(AppRoutes.spotDetail(spotId));
    await tester.pump();

    expect(find.byType(SpotDetailPage), findsOneWidget);
    expect(find.byType(SpotDetailSkeleton), findsOneWidget);
  });

  testWidgets(
    'pendant le chargement, affiche le spot transmis sans ses compteurs',
    (tester) async {
      spots = FakeSpotRepository();
      addTearDown(spots.dispose);
      final container = await pumpApp(
        tester,
        auth: FakeAuthRepository(FakeAuthRepository.user),
        spots: spots,
        overrides: [
          ratingRepositoryProvider.overrideWithValue(FakeRatingRepository()),
          commentRepositoryProvider.overrideWithValue(FakeCommentRepository()),
          spotAuthorRepositoryProvider.overrideWithValue(
            FakeSpotAuthorRepository(),
          ),
        ],
      );
      await tester.pumpAndSettle();
      final withCounters = buildSpot(
        averageRating: 4,
        ratingCount: 3,
        commentCount: 2,
        favoriteCount: 1,
        geohash: 'u09tvw0',
      );
      unawaited(
        container
            .read(routerProvider)
            .push(AppRoutes.spotDetail(spotId), extra: withCounters),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(SpotDetailSkeleton), findsNothing);
      final layout = tester.widget<SpotDetailLayout>(
        find.byType(SpotDetailLayout),
      );
      expect(layout.spot, buildSpot());
    },
  );

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

  testWidgets('l’état d’erreur propose un bouton retour', (tester) async {
    final container = await pumpSpotApp(
      tester,
      failure: const NetworkFailure(),
    );
    container.read(routerProvider).go(AppRoutes.spotDetail(spotId));
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsOneWidget);
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

  void setSurface(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('à 1024 px de large, la galerie et les infos sont côte à côte', (
    tester,
  ) async {
    setSurface(tester, const Size(1024, 768));
    final container = await pumpSpotApp(tester);
    container.read(routerProvider).go(AppRoutes.spotDetail(spotId));
    await tester.pumpAndSettle();

    final gallery = tester.getTopLeft(find.byType(SpotGallery));
    final header = tester.getTopLeft(find.byType(SpotHeader));
    expect(gallery.dx, lessThan(header.dx));
    final galleryBottom = tester.getBottomLeft(find.byType(SpotGallery)).dy;
    expect(header.dy, lessThan(galleryBottom));
  });

  testWidgets('à 390 px de large, la galerie est au-dessus des infos', (
    tester,
  ) async {
    setSurface(tester, const Size(390, 844));
    final container = await pumpSpotApp(tester);
    container.read(routerProvider).go(AppRoutes.spotDetail(spotId));
    await tester.pumpAndSettle();

    final gallery = tester.getTopLeft(find.byType(SpotGallery));
    final header = tester.getTopLeft(find.byType(SpotHeader));
    expect(gallery.dy, lessThan(header.dy));
  });

  testWidgets('à 700 px de large, la fiche reste empilée', (tester) async {
    setSurface(tester, const Size(700, 900));
    final container = await pumpSpotApp(tester);
    container.read(routerProvider).go(AppRoutes.spotDetail(spotId));
    await tester.pumpAndSettle();

    final gallery = tester.getTopLeft(find.byType(SpotGallery));
    final header = tester.getTopLeft(find.byType(SpotHeader));
    expect(gallery.dy, lessThan(header.dy));
  });
}
