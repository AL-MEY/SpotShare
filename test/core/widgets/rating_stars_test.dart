import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/theme/app_theme_impl.dart';
import 'package:spotshare/core/widgets/rating_stars.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: lightTheme,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  testWidgets('affiche 3,5 étoiles en lecture seule', (tester) async {
    await _pump(tester, const RatingStars(value: 3.5));

    expect(find.byIcon(Icons.star), findsNWidgets(3));
    expect(find.byIcon(Icons.star_half), findsOneWidget);
    expect(find.byIcon(Icons.star_border), findsOneWidget);
  });

  testWidgets('un tap sur la 4e étoile appelle onChanged(4)', (tester) async {
    int? picked;
    await _pump(tester, RatingStars(value: 2, onChanged: (n) => picked = n));

    await tester.tap(find.byType(IconButton).at(3));

    expect(picked, 4);
    expect(find.byIcon(Icons.star), findsNWidgets(2));
    expect(find.byIcon(Icons.star_border), findsNWidgets(3));
  });

  testWidgets('sans onChanged, aucune étoile n’est cliquable', (tester) async {
    await _pump(tester, const RatingStars(value: 4));

    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('le tooltip vient du callback semanticLabel', (tester) async {
    await _pump(
      tester,
      RatingStars(value: 1, onChanged: (_) {}, semanticLabel: (n) => 'note $n'),
    );

    expect(find.byTooltip('note 5'), findsOneWidget);
  });
}
