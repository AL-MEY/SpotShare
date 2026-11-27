import 'package:spotshare/core/error/firebase_failure.dart';
import 'package:spotshare/features/spot/data/datasources/comment_remote_data_source.dart';
import 'package:spotshare/features/spot/data/mappers/spot_comment_mapper.dart';
import 'package:spotshare/features/spot/domain/entities/spot_comment.dart';
import 'package:spotshare/features/spot/domain/repositories/comment_repository.dart';

class FirebaseCommentRepository implements CommentRepository {
  const FirebaseCommentRepository(this._remote);

  final CommentRemoteDataSource _remote;

  @override
  Stream<List<SpotComment>> watchComments(
    String spotId, {
    required int limit,
  }) => _remote
      .watchComments(spotId, limit)
      .map((dtos) => dtos.map((d) => d.toEntity()).toList())
      .handleError((Object e) => throw failureFrom(e));

  @override
  Future<void> addComment({
    required String spotId,
    required String authorId,
    required String text,
  }) async {
    try {
      await _remote.addComment(spotId, authorId, text);
    } on Object catch (e) {
      throw failureFrom(e);
    }
  }

  @override
  Future<void> deleteComment({
    required String spotId,
    required String commentId,
  }) async {
    try {
      await _remote.deleteComment(spotId, commentId);
    } on Object catch (e) {
      throw failureFrom(e);
    }
  }
}
