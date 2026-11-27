import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotshare/features/spot/data/models/spot_author_dto.dart';

class SpotAuthorRemoteDataSource {
  SpotAuthorRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  // Le cache vide d'un profil absent est ignoré : on attend le serveur.
  Stream<SpotAuthorDto?> watchAuthor(String userId) => _firestore
      .collection('users')
      .doc(userId)
      .snapshots()
      .where((s) => s.exists || !s.metadata.isFromCache)
      .map((s) => s.exists ? SpotAuthorDto.fromFirestore(s) : null);
}
