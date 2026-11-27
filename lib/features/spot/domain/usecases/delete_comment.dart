import 'package:spotshare/features/spot/domain/repositories/comment_repository.dart';

class DeleteComment {
  const DeleteComment(this._repository);

  final CommentRepository _repository;

  Future<void> call({required String spotId, required String commentId}) =>
      _repository.deleteComment(spotId: spotId, commentId: commentId);
}
