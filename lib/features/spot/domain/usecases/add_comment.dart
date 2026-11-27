import 'package:spotshare/features/spot/domain/repositories/comment_repository.dart';

class AddComment {
  const AddComment(this._repository);

  final CommentRepository _repository;

  Future<void> call({
    required String spotId,
    required String authorId,
    required String text,
  }) => _repository.addComment(
    spotId: spotId,
    authorId: authorId,
    text: text.trim(),
  );
}
