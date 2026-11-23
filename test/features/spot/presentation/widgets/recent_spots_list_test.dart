import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/features/spot/presentation/hero_tags.dart';
import 'package:spotshare/features/spot/presentation/pages/spot_detail_page.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/features/spot/presentation/widgets/recent_spots_list.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_detail_skeleton.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_list_tile.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_comment_repository.dart';
import '../../../../helpers/fake_rating_repository.dart';
import '../../../../helpers/fake_spot_author_repository.dart';
import '../../../../helpers/fake_spot_repository.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/spot_fixtures.dart';

void main() {
  Future<FakeSpotRepository> pumpHome(
    WidgetTester tester,
    FakeSpotRepository spots,
  ) async {
    addTearDown(spots.dispose);
    final authors = FakeSpotAuthorRepository();
    addTearDown(authors.dispose);
    await pumpApp(
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
    return spots;
  }

  testWidgets('affiche les spots récents', (tester) async {
    await pumpHome(
      tester,
      FakeSpotRepository(
        recent: [
          buildSpot(),
          buildSpot(id: 's2', title: 'Vue sur la ville'),
        ],
      ),
    );

    expect(find.byType(RecentSpotsList), findsOneWidget);
    expect(find.text('Spots récents'), findsOneWidget);
    expect(find.text('Café du coin'), findsOneWidget);
    expect(find.text('Vue sur la ville'), findsOneWidget);
  });

  testWidgets('la vignette est enveloppée dans le Hero de la galerie', (
    tester,
  ) async {
    await pumpHome(tester, FakeSpotRepository(recent: [buildSpot()]));

    final hero = tester.widget<Hero>(find.byType(Hero));
    expect(hero.tag, spotMediaHeroTag(spotId, 0));
  });

  testWidgets('ouvre la fiche au tap', (tester) async {
    await pumpHome(
      tester,
      FakeSpotRepository(spot: buildSpot(), recent: [buildSpot()]),
    );

    await tester.tap(find.text('Café du coin'));
    await tester.pumpAndSettle();

    expect(find.byType(SpotDetailPage), findsOneWidget);
  });

  testWidgets('le tap lance la transition Hero vers la galerie de la fiche', (
    tester,
  ) async {
    // La fiche reste en chargement : seul le spot de la liste est disponible.
    await pumpHome(tester, FakeSpotRepository(recent: [buildSpot()]));

    await tester.tap(find.text('Café du coin'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final heroInDetail = find.descendant(
      of: find.byType(SpotDetailPage),
      matching: find.byWidgetPredicate(
        (w) => w is Hero && w.tag == spotMediaHeroTag(spotId, 0),
      ),
      skipOffstage: false,
    );
    expect(heroInDetail, findsOneWidget);
    expect(find.byType(SpotDetailSkeleton), findsNothing);
    // En vol, le Hero source n'affiche plus sa vignette.
    expect(
      find.descendant(
        of: find.byType(SpotListTile),
        matching: find.byType(ClipRRect),
        skipOffstage: false,
      ),
      findsNothing,
    );
    await tester.pumpAndSettle();
  });

  testWidgets('affiche l’état vide', (tester) async {
    await pumpHome(tester, FakeSpotRepository());

    expect(find.text('Aucun spot pour le moment.'), findsOneWidget);
  });

  testWidgets('un spot sans média affiche un placeholder', (tester) async {
    await pumpHome(
      tester,
      FakeSpotRepository(
        recent: [buildSpot(title: 'Sans photo', media: const [])],
      ),
    );

    expect(find.text('Sans photo'), findsOneWidget);
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
  });

  testWidgets('affiche l’erreur puis relance au tap sur Réessayer', (
    tester,
  ) async {
    final spots = FakeSpotRepository(recent: [buildSpot()]);
    spots.failure = const NetworkFailure();
    await pumpHome(tester, spots);

    expect(find.text('Réessayer'), findsOneWidget);

    spots.failure = null;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('Café du coin'), findsOneWidget);
  });
}
