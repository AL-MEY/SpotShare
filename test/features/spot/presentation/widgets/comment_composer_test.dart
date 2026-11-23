import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/features/spot/presentation/widgets/comment_composer.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_comment_repository.dart';
import '../../../../helpers/fake_rating_repository.dart';
import '../../../../helpers/fake_spot_author_repository.dart';
import '../../../../helpers/fake_spot_repository.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/spot_fixtures.dart';

void main() {
  late FakeCommentRepository comments;

  Future<void> pumpSpot(WidgetTester tester, {bool online = true}) async {
    final spots = FakeSpotRepository(spot: buildSpot());
    final authors = FakeSpotAuthorRepository();
    final ratings = FakeRatingRepository();
    comments = FakeCommentRepository();
    addTearDown(spots.dispose);
    addTearDown(authors.dispose);
    addTearDown(ratings.dispose);
    addTearDown(comments.dispose);
    final container = await pumpApp(
      tester,
      auth: FakeAuthRepository(FakeAuthRepository.user),
      online: online,
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
    await tester.scrollUntilVisible(
      find.byType(CommentComposer),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  Finder field() => find.descendant(
    of: find.byType(CommentComposer),
    matching: find.byType(TextField),
  );

  Finder sendButton() => find.widgetWithText(FilledButton, 'Envoyer');

  testWidgets('refuse un commentaire vide', (tester) async {
    await pumpSpot(tester);

    await tester.enterText(field(), '   ');
    await tester.pumpAndSettle();
    await tester.tap(sendButton());
    await tester.pumpAndSettle();

    expect(find.text('Écris quelque chose avant d’envoyer.'), findsOneWidget);
    expect(comments.added, isEmpty);
  });

  testWidgets('refuse un commentaire de 501 caractères', (tester) async {
    await pumpSpot(tester);

    await tester.enterText(field(), 'a' * 501);
    await tester.pumpAndSettle();

    expect(find.text('500 caractères maximum.'), findsOneWidget);
    await tester.tap(sendButton());
    await tester.pumpAndSettle();
    expect(comments.added, isEmpty);
  });

  testWidgets('envoie le commentaire trimé puis vide le champ', (tester) async {
    await pumpSpot(tester);

    await tester.enterText(field(), '  Bravo  ');
    await tester.pumpAndSettle();
    await tester.tap(sendButton());
    await tester.pumpAndSettle();

    expect(comments.added, ['Bravo']);
    expect(tester.widget<TextField>(field()).controller!.text, isEmpty);
    expect(find.text('Écris quelque chose avant d’envoyer.'), findsNothing);
  });

  testWidgets('affiche la bottom sheet quand l’envoi échoue', (tester) async {
    await pumpSpot(tester);
    comments.failure = const PermissionFailure();

    await tester.enterText(field(), 'Bravo');
    await tester.pumpAndSettle();
    await tester.tap(sendButton());
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(tester.widget<TextField>(field()).controller!.text, 'Bravo');
  });

  testWidgets('désactive l’envoi hors ligne', (tester) async {
    await pumpSpot(tester, online: false);

    expect(tester.widget<TextField>(field()).enabled, isFalse);
    expect(tester.widget<FilledButton>(sendButton()).onPressed, isNull);
    expect(
      find.text('Hors connexion, certaines données peuvent être anciennes.'),
      findsWidgets,
    );
  });
}
