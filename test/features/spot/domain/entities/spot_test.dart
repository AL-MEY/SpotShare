import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/features/spot/domain/entities/geo_position.dart';
import 'package:spotshare/features/spot/domain/entities/spot.dart';
import 'package:spotshare/features/spot/domain/entities/spot_category.dart';
import 'package:spotshare/features/spot/domain/entities/spot_media.dart';

Spot buildSpot({List<SpotMedia>? media, List<String>? tags}) => Spot(
  id: 's1',
  title: 'Café du coin',
  description: 'Un super café',
  category: SpotCategory.cafe,
  address: '1 rue de Paris',
  location: const GeoPosition(latitude: 48.85, longitude: 2.35),
  media: media ?? [const SpotPhoto(url: 'https://x/a.jpg')],
  tags: tags ?? ['calme', 'wifi'],
  authorId: 'u1',
  createdAt: DateTime(2026, 11, 23),
  averageRating: 4.5,
  ratingCount: 2,
  commentCount: 1,
  favoriteCount: 2,
);

void main() {
  test('la couverture est la prévisualisation du premier média', () {
    final spot = buildSpot(
      media: [
        const SpotVideo(
          url: 'https://x/v.mp4',
          thumbnailUrl: 'https://x/t.jpg',
          duration: Duration(seconds: 10),
        ),
        const SpotPhoto(url: 'https://x/a.jpg'),
      ],
    );
    expect(spot.coverImageUrl, 'https://x/t.jpg');
  });

  test('pas de couverture sans média', () {
    expect(buildSpot(media: []).coverImageUrl, isNull);
  });

  test('deux spots identiques sont égaux', () {
    final a = buildSpot();
    final b = buildSpot(
      media: [const SpotPhoto(url: 'https://x/a.jpg')],
      tags: ['calme', 'wifi'],
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(buildSpot(tags: ['calme'])));
  });

  test('copyWith remplace favoriteCount et garde le reste', () {
    final spot = buildSpot().copyWith(favoriteCount: 9);
    expect(spot.favoriteCount, 9);
    expect(spot.commentCount, 1);
    expect(spot, isNot(buildSpot()));
  });
}
