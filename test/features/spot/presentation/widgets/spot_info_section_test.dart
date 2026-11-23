import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/core/theme/app_theme_impl.dart';
import 'package:spotshare/features/spot/domain/entities/spot.dart';
import 'package:spotshare/features/spot/domain/entities/spot_author.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_description.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_rating_summary.dart';

import 'package:spotshare/i18n/strings.g.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_comment_repository.dart';
import '../../../../helpers/fake_rating_repository.dart';
import '../../../../helpers/fake_spot_author_repository.dart';
import '../../../../helpers/fake_spot_repository.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/spot_fixtures.dart';

void main() {
  late FakeSpotRepository spots;
  late FakeSpotAuthorRepository authors;

  Future<void> pumpSpot(WidgetTester tester, Spot spot) async {
    spots = FakeSpotRepository(spot: spot);
    authors = FakeSpotAuthorRepository();
    addTearDown(spots.dispose);
    addTearDown(authors.dispose);
    final container = await pumpApp(
      tester,
      auth: FakeAuthRepository(FakeAuthRepository.user),
      spots: spots,
      overrides: [
        ratingRepositoryProvider.overrideWithValue(FakeRatingRepository()),
        commentRepositoryProvider.overrideWithValue(FakeCommentRepository()),
        spotAuthorRepositoryProvider.overrideWithValue(authors),
      ],
    );
    await tester.pumpAndSettle();
    container.read(routerProvider).go(AppRoutes.spotDetail(spot.id));
    await tester.pumpAndSettle();
  }

  testWidgets('affiche catégorie, adresse, tags et auteur', (tester) async {
    await pumpSpot(tester, buildSpot(tags: const ['calme', 'wifi']));

    expect(find.text('Café'), findsOneWidget);
    expect(find.text('1 rue de Rivoli, Paris'), findsOneWidget);
    expect(find.text('#calme'), findsOneWidget);
    expect(find.text('#wifi'), findsOneWidget);
    expect(find.text('Par Camille'), findsOneWidget);
  });

  testWidgets('affiche la note formatée avec la locale', (tester) async {
    await pumpSpot(tester, buildSpot(averageRating: 4.3, ratingCount: 27));

    expect(find.text('4,3 (27 avis)'), findsOneWidget);
  });

  testWidgets('affiche Aucune note quand le spot n’a pas de note', (
    tester,
  ) async {
    await pumpSpot(tester, buildSpot());

    expect(find.text('Pas encore de note'), findsOneWidget);
  });

  testWidgets('copie l’adresse et confirme', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await pumpSpot(tester, buildSpot());

    await tester.tap(find.byTooltip('Copier l’adresse'));
    await tester.pump();

    expect(copied, '1 rue de Rivoli, Paris');
    expect(find.text('Adresse copiée'), findsOneWidget);
  });

  testWidgets('déplie la description longue', (tester) async {
    await pumpSpot(
      tester,
      buildSpot(description: List.filled(400, 'mot').join(' ')),
    );
    Text description() => tester.widget<Text>(
      find.byWidgetPredicate(
        (w) => w is Text && w.maxLines == SpotDescription.collapsedLines,
      ),
    );
    expect(description().maxLines, 5);

    await tester.ensureVisible(find.text('Lire la suite'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lire la suite'));
    await tester.pumpAndSettle();

    expect(find.text('Réduire'), findsOneWidget);
    expect(find.text('Lire la suite'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) => w is Text && w.maxLines == SpotDescription.collapsedLines,
      ),
      findsNothing,
    );
  });

  testWidgets('n’affiche pas Lire la suite pour une description courte', (
    tester,
  ) async {
    await pumpSpot(tester, buildSpot());

    expect(find.text('Un café tranquille'), findsOneWidget);
    expect(find.text('Lire la suite'), findsNothing);
  });

  testWidgets('affiche Auteur inconnu sans profil', (tester) async {
    await pumpSpot(tester, buildSpot());
    authors.emit(null);
    await tester.pumpAndSettle();

    expect(find.text('Auteur inconnu'), findsOneWidget);
  });

  testWidgets('affiche Auteur inconnu quand le nom est vide', (tester) async {
    await pumpSpot(tester, buildSpot());
    authors.emit(const SpotAuthor(id: 'author', displayName: '   '));
    await tester.pumpAndSettle();

    expect(find.text('Auteur inconnu'), findsOneWidget);
    expect(find.textContaining('Par '), findsNothing);
  });

  testWidgets('un titre de 80 caractères ne déborde pas à 320 px de large', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final title = 'A' * Spot.titleMaxLength;

    await pumpSpot(
      tester,
      buildSpot(title: title, ratingCount: 1, averageRating: 5),
    );

    expect(find.text(title), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('une nouvelle note moyenne ne reconstruit pas l’en-tête', (
    tester,
  ) async {
    await pumpSpot(tester, buildSpot(averageRating: 4, ratingCount: 2));
    final title = tester.widget<Text>(find.text('Café du coin'));
    expect(find.text('4,0 (2 avis)'), findsOneWidget);

    spots.emit(buildSpot(averageRating: 3, ratingCount: 3, commentCount: 9));
    await tester.pumpAndSettle();

    expect(find.text('3,0 (3 avis)'), findsOneWidget);
    expect(
      identical(tester.widget<Text>(find.text('Café du coin')), title),
      isTrue,
    );
  });

  testWidgets(
    'SpotRatingSummary ne se reconstruit que pour la note et le compteur',
    (tester) async {
      // Instance const : seuls les changements du provider peuvent la reconstruire.
      const summary = SpotRatingSummary(spotId: spotId);
      var builds = 0;
      final previous = debugOnRebuildDirtyWidget;
      debugOnRebuildDirtyWidget = (element, _) {
        if (element.widget is SpotRatingSummary) builds++;
      };
      addTearDown(() => debugOnRebuildDirtyWidget = previous);
      spots = FakeSpotRepository(
        spot: buildSpot(averageRating: 4, ratingCount: 2),
      );
      addTearDown(spots.dispose);
      await tester.runAsync(() => LocaleSettings.setLocale(AppLocale.fr));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [spotRepositoryProvider.overrideWithValue(spots)],
          child: TranslationProvider(
            child: MaterialApp(
              theme: lightTheme,
              locale: AppLocale.fr.flutterLocale,
              supportedLocales: AppLocaleUtils.supportedLocales,
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              home: const Scaffold(body: summary),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      builds = 0;

      spots.emit(buildSpot(averageRating: 4, ratingCount: 2, commentCount: 9));
      await tester.pumpAndSettle();
      expect(builds, 0);

      spots.emit(buildSpot(averageRating: 3, ratingCount: 3, commentCount: 9));
      await tester.pumpAndSettle();
      expect(builds, 1);
      expect(find.text('3,0 (3 avis)'), findsOneWidget);
    },
  );
}
