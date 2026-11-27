import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotshare/features/spot/data/models/spot_dto.dart';

typedef SpotDocument = ({SpotDto? dto, bool isFromCache});

class SpotRemoteDataSource {
  SpotRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _spots =>
      _firestore.collection('spots');

  Stream<SpotDocument> watchSpot(String spotId) => _spots
      .doc(spotId)
      .snapshots()
      .map(
        (s) => (
          dto: s.exists ? SpotDto.fromFirestore(s) : null,
          isFromCache: s.metadata.isFromCache,
        ),
      );

  Stream<List<SpotDto>> watchRecentSpots(int limit) => _spots
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((q) => q.docs.map(SpotDto.fromFirestore).toList());
}
