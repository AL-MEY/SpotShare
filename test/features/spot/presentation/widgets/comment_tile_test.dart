import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/features/spot/domain/entities/spot_comment.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_comment_repository.dart';
import '../../../../helpers/fake_rating_repository.dart';
import '../../../../helpers/fake_spot_author_repository.dart';
import '../../../../helpers/fake_spot_repository.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/spot_fixtures.dart';

void main() {
  late FakeCommentRepository comments;

  Future<void> pumpSpot(WidgetTester tester, List<SpotComment> initial) async {
    final spots = FakeSpotRepository(spot: buildSpot());
    final authors = FakeSpotAuthorRepository();
    final ratings = FakeRatingRepository();
    comments = FakeCommentRepository(initial);
    addTearDown(spots.dispose);
    addTearDown(authors.dispose);
    addTearDown(ratings.dispose);
    addTearDown(comments.dispose);
    final container = await pumpApp(
      tester,
      auth: FakeAuthRepository(FakeAuthRepository.user),
      overrides: [
        spotRepositoryProvider.overrideWithValue(spots),
        ratingRepositoryProvider.overrideWithValue(ratings),
        commentRepositoryProvider.overrideWithValue(comments),
        spotAuthorRepositoryProvider.overrideWithValue(authors),
      ],
    );
    await tester.pumpAndSettle();
    container.read(routerProvider).go(AppRoutes.spotDetail(spotId));
    await tester.pumpAndSettle();
  }

  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'un commentaire de 500 caractères sans espace ne déborde pas à 320 px de large',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final longWord = 'a' * SpotComment.maxLength;
      await pumpSpot(tester, [buildComment(text: longWord)]);

      await reveal(tester, find.text(longWord));

      expect(find.text(longWord), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
