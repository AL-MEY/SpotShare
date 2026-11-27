import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/features/spot/data/datasources/comment_remote_data_source.dart';
import 'package:spotshare/features/spot/data/models/spot_comment_dto.dart';
import 'package:spotshare/features/spot/data/repositories/firebase_comment_repository.dart';
import 'package:spotshare/features/spot/domain/entities/spot_comment.dart';

class _MockRemote extends Mock implements CommentRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late FirebaseCommentRepository repository;

  setUp(() {
    remote = _MockRemote();
    repository = FirebaseCommentRepository(remote);
  });

  test('convertit les DTO en entités', () async {
    final createdAt = DateTime(2026, 11);
    when(() => remote.watchComments('s1', 10)).thenAnswer(
      (_) => Stream.value([
        SpotCommentDto(
          id: 'c1',
          authorId: 'u1',
          text: 'Super',
          createdAt: createdAt,
        ),
      ]),
    );

    final comments = await repository.watchComments('s1', limit: 10).first;

    expect(comments, [
      SpotComment(
        id: 'c1',
        authorId: 'u1',
        text: 'Super',
        createdAt: createdAt,
      ),
    ]);
  });

  test('ajoute et supprime via la source distante', () async {
    when(() => remote.addComment('s1', 'u1', 'Super')).thenAnswer((_) async {});
    when(() => remote.deleteComment('s1', 'c1')).thenAnswer((_) async {});

    await repository.addComment(spotId: 's1', authorId: 'u1', text: 'Super');
    await repository.deleteComment(spotId: 's1', commentId: 'c1');

    verify(() => remote.addComment('s1', 'u1', 'Super')).called(1);
    verify(() => remote.deleteComment('s1', 'c1')).called(1);
  });

  test('convertit les erreurs en Failure', () async {
    when(() => remote.watchComments('s1', 10)).thenAnswer(
      (_) => Stream.error(FirebaseException(plugin: 'f', code: 'unavailable')),
    );
    when(() => remote.addComment('s1', 'u1', 'x'))
        .thenThrow(FirebaseException(plugin: 'f', code: 'permission-denied'));
    when(() => remote.deleteComment('s1', 'c1'))
        .thenThrow(FirebaseException(plugin: 'f', code: 'permission-denied'));

    expect(
      repository.watchComments('s1', limit: 10),
      emitsError(isA<NetworkFailure>()),
    );
    await expectLater(
      repository.addComment(spotId: 's1', authorId: 'u1', text: 'x'),
      throwsA(isA<PermissionFailure>()),
    );
    await expectLater(
      repository.deleteComment(spotId: 's1', commentId: 'c1'),
      throwsA(isA<PermissionFailure>()),
    );
  });
}
