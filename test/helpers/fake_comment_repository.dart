import 'dart:async';

import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/features/spot/domain/entities/spot_comment.dart';
import 'package:spotshare/features/spot/domain/repositories/comment_repository.dart';

class FakeCommentRepository implements CommentRepository {
  FakeCommentRepository([List<SpotComment>? comments])
    : _comments = comments ?? [];

  List<SpotComment> _comments;
  Failure? failure;
  final added = <String>[];
  final deleted = <String>[];
  final requestedLimits = <int>[];
  final _controller = StreamController<List<SpotComment>>.broadcast();

  Future<void> dispose() => _controller.close();

  void emit(List<SpotComment> comments) {
    _comments = comments;
    _controller.add(comments);
  }

  @override
  Stream<List<SpotComment>> watchComments(
    String spotId, {
    required int limit,
  }) async* {
    requestedLimits.add(limit);
    final failure = this.failure;
    if (failure != null) throw failure;
    yield _comments;
    yield* _controller.stream;
  }

  @override
  Future<void> addComment({
    required String spotId,
    required String authorId,
    required String text,
  }) async {
    final failure = this.failure;
    if (failure != null) throw failure;
    added.add(text);
  }

  @override
  Future<void> deleteComment({
    required String spotId,
    required String commentId,
  }) async {
    final failure = this.failure;
    if (failure != null) throw failure;
    deleted.add(commentId);
  }
}
