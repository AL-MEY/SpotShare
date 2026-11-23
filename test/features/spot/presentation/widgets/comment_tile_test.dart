import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/features/spot/domain/entities/spot_comment.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/features/spot/presentation/widgets/comment_tile.dart';

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

  Finder deleteButtons() => find.byTooltip('Supprimer');

  testWidgets('le bouton supprimer n’apparaît que sur mes commentaires', (
    tester,
  ) async {
    await pumpSpot(tester, [
      buildComment(authorId: 'uid', text: 'Le mien'),
      buildComment(id: 'c2', text: 'Celui d’un autre'),
    ]);

    await reveal(tester, find.text('Celui d’un autre'));

    expect(deleteButtons(), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(CommentTile, 'Le mien'),
        matching: deleteButtons(),
      ),
      findsOneWidget,
    );
  });

  testWidgets('supprime après confirmation, rien après annulation', (
    tester,
  ) async {
    await pumpSpot(tester, [buildComment(authorId: 'uid')]);
    await reveal(tester, deleteButtons());

    await tester.tap(deleteButtons());
    await tester.pumpAndSettle();
    expect(find.text('Supprimer le commentaire ?'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(comments.deleted, isEmpty);

    await tester.tap(deleteButtons());
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
    await tester.pumpAndSettle();
    expect(comments.deleted, ['c1']);
    comments.emit([]);
    await tester.pumpAndSettle();
    expect(find.text('Super endroit'), findsNothing);
  });

  testWidgets('affiche la bottom sheet quand la suppression échoue', (
    tester,
  ) async {
    await pumpSpot(tester, [buildComment(authorId: 'uid')]);
    await reveal(tester, deleteButtons());
    comments.failure = const PermissionFailure();

    await tester.tap(deleteButtons());
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
  });
}
