import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/features/spot/data/datasources/rating_remote_data_source.dart';
import 'package:spotshare/features/spot/data/repositories/firebase_rating_repository.dart';
import 'package:spotshare/features/spot/domain/entities/rating.dart';

class _MockRemote extends Mock implements RatingRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late FirebaseRatingRepository repository;

  setUp(() {
    remote = _MockRemote();
    repository = FirebaseRatingRepository(remote);
  });

  test('convertit la valeur stockée en Rating', () async {
    when(() => remote.watchRating('s1', 'u1'))
        .thenAnswer((_) => Stream.value(4));

    final rating = await repository
        .watchMyRating(spotId: 's1', userId: 'u1')
        .first;

    expect(rating, Rating(4));
  });

  test('une valeur stockée invalide est lue comme absente', () async {
    when(() => remote.watchRating('s1', 'u1'))
        .thenAnswer((_) => Stream.fromIterable([0, 6, null]));

    final ratings = await repository
        .watchMyRating(spotId: 's1', userId: 'u1')
        .toList();

    expect(ratings, [null, null, null]);
  });

  test('rate écrit la valeur du Rating', () async {
    when(() => remote.setRating('s1', 'u1', 5)).thenAnswer((_) async {});

    await repository.rate(spotId: 's1', userId: 'u1', rating: Rating(5));

    verify(() => remote.setRating('s1', 'u1', 5)).called(1);
  });

  test('convertit les erreurs en Failure', () async {
    when(() => remote.watchRating('s1', 'u1')).thenAnswer(
      (_) => Stream.error(FirebaseException(plugin: 'f', code: 'unavailable')),
    );
    when(() => remote.setRating('s1', 'u1', 2))
        .thenThrow(FirebaseException(plugin: 'f', code: 'permission-denied'));

    expect(
      repository.watchMyRating(spotId: 's1', userId: 'u1'),
      emitsError(isA<NetworkFailure>()),
    );
    await expectLater(
      repository.rate(spotId: 's1', userId: 'u1', rating: Rating(2)),
      throwsA(isA<PermissionFailure>()),
    );
  });
}
