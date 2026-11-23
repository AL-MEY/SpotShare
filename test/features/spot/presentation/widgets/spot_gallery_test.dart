import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/features/spot/domain/entities/spot.dart';
import 'package:spotshare/features/spot/domain/entities/spot_media.dart';
import 'package:spotshare/features/spot/presentation/pages/spot_media_viewer_page.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_gallery.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_comment_repository.dart';
import '../../../../helpers/fake_rating_repository.dart';
import '../../../../helpers/fake_spot_author_repository.dart';
import '../../../../helpers/fake_spot_repository.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/spot_fixtures.dart';

void main() {
  Future<void> pumpSpot(WidgetTester tester, Spot spot) async {
    final spots = FakeSpotRepository(spot: spot);
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
    container.read(routerProvider).go(AppRoutes.spotDetail(spot.id));
    await tester.pumpAndSettle();
  }

  final threePhotos = [
    for (var i = 1; i <= 3; i++)
      SpotPhoto(url: 'https://example.com/photo$i.jpg'),
  ];

  testWidgets('affiche la position 1 sur 3 puis 2 sur 3 après un swipe', (
    tester,
  ) async {
    await pumpSpot(tester, buildSpot(media: threePhotos));

    expect(find.text('1 sur 3'), findsOneWidget);

    await tester.fling(find.byType(SpotGallery), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('2 sur 3'), findsOneWidget);
  });

  testWidgets('ouvre le plein écran sur le média touché', (tester) async {
    await pumpSpot(tester, buildSpot(media: threePhotos));

    await tester.fling(find.byType(SpotGallery), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SpotGallery));
    await tester.pumpAndSettle();

    expect(find.byType(SpotMediaViewerPage), findsOneWidget);
    expect(find.text('2 sur 3'), findsWidgets);
    expect(find.byTooltip('Fermer'), findsOneWidget);
  });

  testWidgets('une vidéo apparaît en vignette avec sa durée', (tester) async {
    await pumpSpot(
      tester,
      buildSpot(
        media: const [
          SpotVideo(
            url: 'https://example.com/v.mp4',
            thumbnailUrl: 'https://example.com/v.jpg',
            duration: Duration(seconds: 65),
          ),
        ],
      ),
    );

    expect(find.text('1:05'), findsOneWidget);
    expect(find.byIcon(Icons.play_circle_fill), findsOneWidget);
  });

  testWidgets('un spot sans média affiche un placeholder', (tester) async {
    await pumpSpot(tester, buildSpot(media: const []));

    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
  });
}
