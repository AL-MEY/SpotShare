import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotshare/features/spot/data/models/spot_comment_dto.dart';

class CommentRemoteDataSource {
  CommentRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _comments(String spotId) =>
      _firestore.collection('spots/$spotId/comments');

  Stream<List<SpotCommentDto>> watchComments(String spotId, int limit) =>
      _comments(spotId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((q) => q.docs.map(SpotCommentDto.fromFirestore).toList());

  Future<void> addComment(String spotId, String authorId, String text) =>
      _comments(spotId).add({
        'authorId': authorId,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> deleteComment(String spotId, String commentId) =>
      _comments(spotId).doc(commentId).delete();
}
