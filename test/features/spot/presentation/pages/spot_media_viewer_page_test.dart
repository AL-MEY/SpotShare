import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/features/spot/domain/entities/spot_media.dart';
import 'package:spotshare/features/spot/presentation/pages/spot_detail_page.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_video_player.dart';
import 'package:spotshare/features/spot/presentation/widgets/zoomable_photo.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_comment_repository.dart';
import '../../../../helpers/fake_rating_repository.dart';
import '../../../../helpers/fake_spot_author_repository.dart';
import '../../../../helpers/fake_spot_repository.dart';
import '../../../../helpers/fake_video_player_controller.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/spot_fixtures.dart';

void main() {
  Future<void> pumpViewer(
    WidgetTester tester,
    int index, {
    Failure? failure,
    List<SpotMedia>? media,
  }) async {
    final spots = FakeSpotRepository(
      spot: buildSpot(
        media:
            media ??
            const [
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
      spots: spots,
      auth: FakeAuthRepository(FakeAuthRepository.user),
      overrides: [
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

  testWidgets('un glissement sur une photo zoomée ne change pas de page', (
    tester,
  ) async {
    await pumpViewer(tester, 0);

    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    viewer.transformationController!.value = Matrix4.diagonal3Values(2, 2, 1);
    await tester.pump();
    await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('1 sur 2'), findsOneWidget);
  });

  testWidgets('le défilement revient quand la photo est dézoomée', (
    tester,
  ) async {
    await pumpViewer(tester, 0);
    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    viewer.transformationController!.value = Matrix4.diagonal3Values(2, 2, 1);
    await tester.pump();

    viewer.transformationController!.value = Matrix4.identity();
    await tester.pump();
    await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('2 sur 2'), findsOneWidget);
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

  testWidgets('le plein écran d’une vidéo affiche son lecteur', (tester) async {
    await pumpViewer(
      tester,
      0,
      media: const [
        SpotVideo(
          url: 'https://example.com/video.mp4',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          duration: Duration(seconds: 12),
        ),
      ],
    );

    expect(find.byType(SpotVideoPlayer), findsOneWidget);
  });

  group('vidéo', () {
    late FakeVideoPlayerController video;

    Future<void> pumpVideo(WidgetTester tester) async {
      video = FakeVideoPlayerController();
      final spots = FakeSpotRepository(
        spot: buildSpot(
          media: const [
            SpotVideo(
              url: 'https://example.com/video.mp4',
              thumbnailUrl: 'https://example.com/thumb.jpg',
              duration: Duration(seconds: 12),
            ),
          ],
        ),
      );
      addTearDown(spots.dispose);
      final container = await pumpApp(
        tester,
        spots: spots,
        auth: FakeAuthRepository(FakeAuthRepository.user),
        overrides: [
          ratingRepositoryProvider.overrideWithValue(FakeRatingRepository()),
          commentRepositoryProvider.overrideWithValue(FakeCommentRepository()),
          spotAuthorRepositoryProvider.overrideWithValue(
            FakeSpotAuthorRepository(),
          ),
          videoControllerFactoryProvider.overrideWithValue((_) => video),
        ],
      );
      await tester.pumpAndSettle();
      container.read(routerProvider).go(AppRoutes.spotMedia(spotId, 0));
      await tester.pump();
      await tester.pump();
    }

    testWidgets('affiche un indicateur pendant l’initialisation', (
      tester,
    ) async {
      await pumpVideo(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      video.completeInitialization();
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets(
      'un tap avant l’initialisation lance la lecture une fois prête',
      (tester) async {
        await pumpVideo(tester);

        await tester.tap(find.byType(SpotVideoPlayer));
        await tester.pump();
        expect(video.value.isPlaying, isFalse);

        video.completeInitialization();
        await tester.pumpAndSettle();
        expect(video.value.isPlaying, isTrue);
      },
    );

    testWidgets('en lecture, la zone vidéo est annoncée Mettre en pause', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpVideo(tester);
      video.completeInitialization();
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Mettre en pause'), findsNothing);

      await tester.tap(find.byType(SpotVideoPlayer));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Mettre en pause'), findsOneWidget);
      semantics.dispose();
    });
  });
}
