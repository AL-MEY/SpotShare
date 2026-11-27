import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/features/spot/data/mappers/spot_mapper.dart';
import 'package:spotshare/features/spot/data/models/spot_dto.dart';
import 'package:spotshare/features/spot/domain/entities/geo_position.dart';
import 'package:spotshare/features/spot/domain/entities/spot_category.dart';
import 'package:spotshare/features/spot/domain/entities/spot_media.dart';

SpotDto _dto({String category = 'cafe', List<SpotMediaDto> media = const []}) =>
    SpotDto(
      id: 's1',
      title: 'Café du coin',
      description: 'Un café tranquille',
      category: category,
      address: '1 rue de Rivoli',
      location: const GeoPoint(48.8566, 2.3522),
      media: media,
      tags: const ['calme'],
      authorId: 'author',
      createdAt: DateTime(2026, 11),
      averageRating: 4.5,
      ratingCount: 2,
      commentCount: 1,
      favoriteCount: 4,
      geohash: 'u09tunq6q',
    );

void main() {
  test('convertit tous les champs en entité', () {
    final spot = _dto().toEntity();

    expect(spot.id, 's1');
    expect(spot.category, SpotCategory.cafe);
    expect(
      spot.location,
      const GeoPosition(latitude: 48.8566, longitude: 2.3522),
    );
    expect(spot.tags, ['calme']);
    expect(spot.averageRating, 4.5);
    expect(spot.ratingCount, 2);
    expect(spot.commentCount, 1);
    expect(spot.favoriteCount, 4);
    expect(spot.geohash, 'u09tunq6q');
  });

  test('une catégorie inconnue devient other', () {
    expect(_dto(category: 'inconnue').toEntity().category, SpotCategory.other);
  });

  test('convertit photo et vidéo dans l’ordre', () {
    final spot = _dto(
      media: const [
        SpotMediaDto(type: 'photo', url: 'p1'),
        SpotMediaDto(
          type: 'video',
          url: 'v1',
          thumbnailUrl: 't1',
          durationMs: 12000,
        ),
        SpotMediaDto(type: 'photo', url: 'p2'),
      ],
    ).toEntity();

    expect(spot.media, const [
      SpotPhoto(url: 'p1'),
      SpotVideo(url: 'v1', thumbnailUrl: 't1', duration: Duration(seconds: 12)),
      SpotPhoto(url: 'p2'),
    ]);
  });

  test('ignore un média de type inconnu', () {
    final spot = _dto(
      media: const [
        SpotMediaDto(type: 'audio', url: 'a1'),
        SpotMediaDto(type: 'photo', url: 'p1'),
      ],
    ).toEntity();

    expect(spot.media, const [SpotPhoto(url: 'p1')]);
  });

  test('ignore une vidéo sans vignette', () {
    final spot = _dto(
      media: const [
        SpotMediaDto(type: 'video', url: 'v1', durationMs: 1000),
        SpotMediaDto(type: 'video', url: 'v2', thumbnailUrl: 't2'),
        SpotMediaDto(type: 'photo', url: 'p1'),
      ],
    ).toEntity();

    expect(spot.media, const [SpotPhoto(url: 'p1')]);
  });

  test('un spot dont aucun média n’est valide a une liste vide', () {
    final spot = _dto(
      media: const [
        SpotMediaDto(type: 'audio', url: 'a1'),
        SpotMediaDto(type: 'video', url: 'v1'),
      ],
    ).toEntity();

    expect(spot.media, isEmpty);
  });

  test('ignore un média sans type', () {
    final spot = _dto(
      media: const [
        SpotMediaDto(url: 'x'),
        SpotMediaDto(type: 'photo', url: 'p1'),
      ],
    ).toEntity();

    expect(spot.media, const [SpotPhoto(url: 'p1')]);
  });

  test('ignore un média sans url', () {
    final spot = _dto(
      media: const [
        SpotMediaDto(type: 'photo'),
        SpotMediaDto(type: 'video', thumbnailUrl: 't', durationMs: 1000),
        SpotMediaDto(type: 'photo', url: 'p1'),
      ],
    ).toEntity();

    expect(spot.media, const [SpotPhoto(url: 'p1')]);
  });
}
