import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/features/spot/domain/entities/spot_media.dart';
import 'package:spotshare/features/spot/presentation/pages/spot_detail_page.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/features/spot/presentation/widgets/zoomable_photo.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_comment_repository.dart';
import '../../../../helpers/fake_rating_repository.dart';
import '../../../../helpers/fake_spot_author_repository.dart';
import '../../../../helpers/fake_spot_repository.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/spot_fixtures.dart';

void main() {
  Future<void> pumpViewer(
    WidgetTester tester,
    int index, {
    Failure? failure,
  }) async {
    final spots = FakeSpotRepository(
      spot: buildSpot(
        media: const [
          SpotPhoto(url: 'https://example.com/photo1.jpg'),
          SpotPhoto(url: 'https://example.com/photo2.jpg'),
        ],
      ),
    );
    spots.failure = failure;
    addTearDown(spots.dispose);
    final authors = FakeSpotAuthorRepository();
    addTearDown(authors.dispose);
    final container = await pumpApp(
      tester,
      auth: FakeAuthRepository(FakeAuthRepository.user),
      overrides: [
        spotRepositoryProvider.overrideWithValue(spots),
        ratingRepositoryProvider.overrideWithValue(FakeRatingRepository()),
        commentRepositoryProvider.overrideWithValue(FakeCommentRepository()),
        spotAuthorRepositoryProvider.overrideWithValue(authors),
      ],
    );
    await tester.pumpAndSettle();
    container.read(routerProvider).go(AppRoutes.spotMedia(spotId, index));
    await tester.pumpAndSettle();
  }

  testWidgets('un index hors bornes ouvre le dernier média', (tester) async {
    await pumpViewer(tester, 99);

    expect(find.text('2 sur 2'), findsOneWidget);
    expect(find.byType(ZoomablePhoto), findsOneWidget);
  });

  testWidgets('un index valide ouvre le média demandé', (tester) async {
    await pumpViewer(tester, 0);

    expect(find.text('1 sur 2'), findsOneWidget);
  });

  testWidgets('affiche l’erreur quand le spot est introuvable', (tester) async {
    await pumpViewer(tester, 0, failure: const NotFoundFailure());

    expect(find.text('Introuvable'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byTooltip('Fermer'), findsOneWidget);
  });

  testWidgets('fermer revient à la fiche même sans historique', (tester) async {
    await pumpViewer(tester, 0);

    await tester.tap(find.byTooltip('Fermer'));
    await tester.pumpAndSettle();

    expect(find.byType(SpotDetailPage), findsOneWidget);
  });
}
