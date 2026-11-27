import 'package:cloud_firestore/cloud_firestore.dart';

class RatingRemoteDataSource {
  RatingRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _rating(
    String spotId,
    String userId,
  ) => _firestore.collection('spots/$spotId/ratings').doc(userId);

  Stream<int?> watchRating(String spotId, String userId) =>
      _rating(spotId, userId).snapshots().map((s) {
        final value = s.data()?['value'];
        return value is int ? value : null;
      });

  Future<void> setRating(String spotId, String userId, int value) => _rating(
    spotId,
    userId,
  ).set({'value': value, 'updatedAt': FieldValue.serverTimestamp()});
}
