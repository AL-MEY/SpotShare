import 'package:spotshare/features/spot/domain/entities/spot_comment.dart';

abstract interface class CommentRepository {
  Stream<List<SpotComment>> watchComments(String spotId, {required int limit});

  Future<void> addComment({
    required String spotId,
    required String authorId,
    required String text,
  });

  Future<void> deleteComment({
    required String spotId,
    required String commentId,
  });
}
