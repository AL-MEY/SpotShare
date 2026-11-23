import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/network/connectivity_provider.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/features/spot/domain/entities/rating.dart';
import 'package:spotshare/features/spot/domain/entities/spot.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_comment_repository.dart';
import '../../../../helpers/fake_rating_repository.dart';
import '../../../../helpers/fake_spot_author_repository.dart';
import '../../../../helpers/fake_spot_repository.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/spot_fixtures.dart';

void main() {
  late FakeRatingRepository ratings;

  Future<void> pumpSpot(
    WidgetTester tester,
    Spot spot, {
    Rating? myRating,
    bool online = true,
  }) async {
    final spots = FakeSpotRepository(spot: spot);
    final authors = FakeSpotAuthorRepository();
    ratings = FakeRatingRepository(myRating);
    addTearDown(spots.dispose);
    addTearDown(authors.dispose);
    addTearDown(ratings.dispose);
    final container = await pumpApp(
      tester,
      auth: FakeAuthRepository(FakeAuthRepository.user),
      overrides: [
        spotRepositoryProvider.overrideWithValue(spots),
        ratingRepositoryProvider.overrideWithValue(ratings),
        commentRepositoryProvider.overrideWithValue(FakeCommentRepository()),
        spotAuthorRepositoryProvider.overrideWithValue(authors),
        isOnlineProvider.overrideWith((ref) => Stream.value(online)),
      ],
    );
    await tester.pumpAndSettle();
    container.read(routerProvider).go(AppRoutes.spotDetail(spot.id));
    await tester.pumpAndSettle();
  }

  Future<void> tapStar(WidgetTester tester, int n) async {
    // Laisse finir l'animation de l'AnimatedSwitcher : un seul enfant.
    await tester.pumpAndSettle();
    final star = find.byTooltip(
      n == 1 ? 'Donner 1 étoile' : 'Donner $n étoiles',
    );
    await tester.ensureVisible(star);
    await tester.pumpAndSettle();
    await tester.tap(star);
    await tester.pump();
  }

  int filledStars() => find.byIcon(Icons.star).evaluate().length;

  testWidgets('un tap sur la 4e étoile enregistre la note 4', (tester) async {
    await pumpSpot(tester, buildSpot());

    await tapStar(tester, 4);
    await tester.pumpAndSettle();

    expect(ratings.rated, [Rating(4)]);
    expect(filledStars(), 4);
  });

  testWidgets('affiche la note existante de l’utilisateur', (tester) async {
    await pumpSpot(tester, buildSpot(), myRating: Rating(3));

    expect(find.text('Ta note'), findsOneWidget);
    expect(filledStars(), 3);
  });

  testWidgets('affiche la bottom sheet d’erreur quand la note est refusée', (
    tester,
  ) async {
    await pumpSpot(tester, buildSpot(), myRating: Rating(2));
    ratings.failure = const PermissionFailure();

    await tapStar(tester, 5);
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(filledStars(), 2);
  });

  testWidgets('désactive les étoiles hors ligne', (tester) async {
    await pumpSpot(tester, buildSpot(), online: false);

    final offline = find.text(
      'Hors connexion, certaines données peuvent être anciennes.',
    );
    await tester.ensureVisible(offline);
    await tester.pumpAndSettle();

    expect(offline, findsOneWidget);
    expect(find.byTooltip('Donner 4 étoiles'), findsNothing);
    expect(ratings.rated, isEmpty);
  });

  testWidgets('masque la notation sur son propre spot', (tester) async {
    await pumpSpot(tester, buildSpot(authorId: 'uid'));

    expect(find.text('Tu ne peux pas noter ton propre spot.'), findsOneWidget);
    expect(find.byTooltip('Donner 4 étoiles'), findsNothing);
  });

  testWidgets(
    'deux taps rapides (3 puis 5) enregistrent 5 en dernier et affichent 5',
    (tester) async {
      await pumpSpot(tester, buildSpot());
      final pending = Completer<void>();
      ratings.pending = pending;

      await tapStar(tester, 3);
      await tapStar(tester, 5);
      pending.complete();
      await tester.pumpAndSettle();

      expect(ratings.rated, [Rating(3), Rating(5)]);
      expect(filledStars(), 5);
      await tapStar(tester, 2);
      await tester.pumpAndSettle();
      expect(ratings.rated.last, Rating(2));
    },
  );
}
