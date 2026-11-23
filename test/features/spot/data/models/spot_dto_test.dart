import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/features/spot/data/models/spot_dto.dart';

Future<DocumentSnapshot<Map<String, dynamic>>> _snapshot(
  Map<String, dynamic> data,
) async {
  final firestore = FakeFirebaseFirestore();
  await firestore.collection('spots').doc('s1').set(data);
  return firestore.collection('spots').doc('s1').get();
}

void main() {
  final base = <String, dynamic>{
    'title': 'Café du coin',
    'description': 'Un café tranquille',
    'category': 'cafe',
    'address': '1 rue de Rivoli',
    'location': const GeoPoint(48.8566, 2.3522),
    'media': [
      {'type': 'photo', 'url': 'https://example.com/p.jpg'},
      {
        'type': 'video',
        'url': 'https://example.com/v.mp4',
        'thumbnailUrl': 'https://example.com/t.jpg',
        'durationMs': 12000,
      },
    ],
    'tags': ['calme'],
    'authorId': 'author',
    'createdAt': Timestamp.fromDate(DateTime(2026, 11)),
  };

  test('lit un document complet', () async {
    final dto = SpotDto.fromFirestore(
      await _snapshot({
        ...base,
        'averageRating': 4,
        'ratingCount': 3,
        'commentCount': 2,
        'favoriteCount': 7,
      }),
    );

    expect(dto.id, 's1');
    expect(dto.title, 'Café du coin');
    expect(dto.category, 'cafe');
    expect(dto.location, const GeoPoint(48.8566, 2.3522));
    expect(dto.media, hasLength(2));
    expect(dto.media.last.thumbnailUrl, 'https://example.com/t.jpg');
    expect(dto.media.last.durationMs, 12000);
    expect(dto.tags, ['calme']);
    expect(dto.authorId, 'author');
    expect(dto.createdAt, DateTime(2026, 11));
    expect(dto.averageRating, 4.0);
    expect(dto.ratingCount, 3);
    expect(dto.commentCount, 2);
    expect(dto.favoriteCount, 7);
  });

  test('les compteurs absents valent 0', () async {
    final dto = SpotDto.fromFirestore(await _snapshot(base));

    expect(dto.averageRating, 0);
    expect(dto.ratingCount, 0);
    expect(dto.commentCount, 0);
    expect(dto.favoriteCount, 0);
  });

  test('un média sans type ni url ne fait pas planter la lecture', () async {
    final dto = SpotDto.fromFirestore(
      await _snapshot({
        ...base,
        'media': [
          {'url': 'x'},
          {'type': 'photo'},
          {'type': 3, 'url': 4},
        ],
      }),
    );

    expect(dto.media, hasLength(3));
  });
}
