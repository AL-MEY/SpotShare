import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/features/spot/data/datasources/spot_author_remote_data_source.dart';
import 'package:spotshare/features/spot/data/models/spot_author_dto.dart';
import 'package:spotshare/features/spot/data/repositories/firebase_spot_author_repository.dart';
import 'package:spotshare/features/spot/domain/entities/spot_author.dart';

class _MockRemote extends Mock implements SpotAuthorRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late FirebaseSpotAuthorRepository repository;

  setUp(() {
    remote = _MockRemote();
    repository = FirebaseSpotAuthorRepository(remote);
  });

  test('convertit le DTO en entité et propage null', () async {
    when(() => remote.watchAuthor('u1')).thenAnswer(
      (_) => Stream.fromIterable([
        const SpotAuthorDto(id: 'u1', displayName: 'Alice'),
        null,
      ]),
    );

    final authors = await repository.watchAuthor('u1').toList();

    expect(authors, [const SpotAuthor(id: 'u1', displayName: 'Alice'), null]);
  });

  test('convertit les erreurs en Failure', () {
    when(() => remote.watchAuthor('u1')).thenAnswer(
      (_) => Stream.error(FirebaseException(plugin: 'f', code: 'unavailable')),
    );

    expect(repository.watchAuthor('u1'), emitsError(isA<NetworkFailure>()));
  });
}
