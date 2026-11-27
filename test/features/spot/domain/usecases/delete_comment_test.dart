import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotshare/features/spot/domain/repositories/comment_repository.dart';
import 'package:spotshare/features/spot/domain/usecases/delete_comment.dart';

class _MockCommentRepository extends Mock implements CommentRepository {}

void main() {
  test('DeleteComment supprime le commentaire demandé', () async {
    final repository = _MockCommentRepository();
    when(
      () => repository.deleteComment(
        spotId: any(named: 'spotId'),
        commentId: any(named: 'commentId'),
      ),
    ).thenAnswer((_) async {});

    await DeleteComment(repository)(spotId: 's1', commentId: 'c1');

    verify(() => repository.deleteComment(spotId: 's1', commentId: 'c1'))
        .called(1);
  });
}
