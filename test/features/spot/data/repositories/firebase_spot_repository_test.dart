import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/features/spot/data/datasources/spot_remote_data_source.dart';
import 'package:spotshare/features/spot/data/models/spot_dto.dart';
import 'package:spotshare/features/spot/data/repositories/firebase_spot_repository.dart';
import 'package:spotshare/features/spot/domain/entities/spot_category.dart';

class _MockRemote extends Mock implements SpotRemoteDataSource {}

final _dto = SpotDto(
  id: 's1',
  title: 'Café du coin',
  description: 'desc',
  category: 'cafe',
  address: 'adresse',
  location: const GeoPoint(48.85, 2.35),
  media: const [],
  tags: const [],
  authorId: 'author',
  createdAt: DateTime(2026, 11),
  averageRating: 0,
  ratingCount: 0,
  commentCount: 0,
);

void main() {
  late _MockRemote remote;
  late FirebaseSpotRepository repository;

  setUp(() {
    remote = _MockRemote();
    repository = FirebaseSpotRepository(remote);
  });

  test('convertit le DTO en entité', () async {
    when(() => remote.watchSpot('s1'))
        .thenAnswer((_) => Stream.value((dto: _dto, isFromCache: false)));

    final spot = await repository.watchSpot('s1').first;

    expect(spot.id, 's1');
    expect(spot.category, SpotCategory.cafe);
  });

  test('lève NotFoundFailure quand le serveur ne trouve pas le spot', () {
    when(() => remote.watchSpot('s1'))
        .thenAnswer((_) => Stream.value((dto: null, isFromCache: false)));

    expect(repository.watchSpot('s1'), emitsError(isA<NotFoundFailure>()));
  });

  test('lève NetworkFailure quand le spot est absent du cache', () {
    when(() => remote.watchSpot('s1'))
        .thenAnswer((_) => Stream.value((dto: null, isFromCache: true)));

    expect(repository.watchSpot('s1'), emitsError(isA<NetworkFailure>()));
  });

  test(
    'convertit une FirebaseException permission-denied en PermissionFailure',
    () {
      when(() => remote.watchSpot('s1')).thenAnswer(
        (_) => Stream.error(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
        ),
      );

      expect(repository.watchSpot('s1'), emitsError(isA<PermissionFailure>()));
    },
  );

  test('convertit les spots récents en entités', () async {
    when(() => remote.watchRecentSpots(5))
        .thenAnswer((_) => Stream.value([_dto]));

    final spots = await repository.watchRecentSpots(limit: 5).first;

    expect(spots.single.id, 's1');
  });
}
