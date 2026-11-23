import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/features/spot/domain/repositories/comment_repository.dart';
import 'package:spotshare/features/spot/domain/usecases/add_comment.dart';

class _MockCommentRepository extends Mock implements CommentRepository {}

void main() {
  late _MockCommentRepository repository;

  setUp(() {
    repository = _MockCommentRepository();
  });

  void stubAddComment(Future<void> Function() answer) {
    when(
      () => repository.addComment(
        spotId: any(named: 'spotId'),
        authorId: any(named: 'authorId'),
        text: any(named: 'text'),
      ),
    ).thenAnswer((_) => answer());
  }

  test('AddComment retire les espaces autour du texte', () async {
    stubAddComment(() async {});

    await AddComment(repository)(
      spotId: 's1',
      authorId: 'u1',
      text: '  Super café  ',
    );

    verify(
      () => repository.addComment(
        spotId: 's1',
        authorId: 'u1',
        text: 'Super café',
      ),
    ).called(1);
  });

  test('AddComment propage la Failure du repository', () {
    stubAddComment(() async => throw const NetworkFailure());

    expect(
      AddComment(repository)(spotId: 's1', authorId: 'u1', text: 'Top'),
      throwsA(isA<NetworkFailure>()),
    );
  });
}
