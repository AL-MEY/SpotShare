import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/features/spot/domain/entities/spot_author.dart';
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

  Future<void> pumpSpot(
    WidgetTester tester, {
    List<SpotComment> initial = const [],
    SpotAuthor? author = FakeSpotAuthorRepository.author,
    int commentCount = 0,
  }) async {
    final spots = FakeSpotRepository(
      spot: buildSpot(commentCount: commentCount),
    );
    final authors = FakeSpotAuthorRepository(author);
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

  testWidgets('affiche Aucun commentaire quand la liste est vide', (
    tester,
  ) async {
    await pumpSpot(tester);

    final none = find.text(
      'Aucun commentaire pour le moment. Lance la discussion !',
    );
    await reveal(tester, none);
    expect(none, findsOneWidget);
  });

  testWidgets('affiche le nom de l’auteur du commentaire', (tester) async {
    await pumpSpot(tester, initial: [buildComment()]);

    final text = find.text('Super endroit');
    await reveal(tester, text);
    expect(find.text('Camille'), findsOneWidget);
  });

  testWidgets('affiche Auteur inconnu quand le nom est vide', (tester) async {
    await pumpSpot(
      tester,
      initial: [buildComment()],
      author: const SpotAuthor(id: 'author', displayName: '  '),
    );

    await reveal(tester, find.text('Super endroit'));
    expect(find.text('Auteur inconnu'), findsWidgets);
  });

  testWidgets('Voir plus charge la page suivante', (tester) async {
    final page = List.generate(
      20,
      (i) => buildComment(id: 'c$i', text: 'Commentaire $i'),
    );
    await pumpSpot(tester, initial: page);
    expect(comments.requestedLimits, [20]);

    final more = find.text('Voir plus de commentaires');
    await reveal(tester, more);
    await tester.tap(more);
    await tester.pumpAndSettle();

    expect(comments.requestedLimits, [20, 40]);
  });

  testWidgets('masque Voir plus quand la page n’est pas pleine', (
    tester,
  ) async {
    await pumpSpot(tester, initial: [buildComment()]);

    await reveal(tester, find.text('Super endroit'));
    expect(find.text('Voir plus de commentaires'), findsNothing);
  });

  testWidgets('le titre affiche le compteur du spot', (tester) async {
    await pumpSpot(tester, commentCount: 3);

    final title = find.text('3 commentaires');
    await reveal(tester, title);
    expect(title, findsOneWidget);
  });
}
