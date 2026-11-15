import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:spotshare/features/profile/data/models/user_profile_dto.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  DocumentReference<Map<String, dynamic>> _doc(String userId) =>
      _firestore.collection('users').doc(userId);

  Stream<UserProfileDto?> watchProfile(String userId) =>
      _doc(userId)
          .snapshots()
          .where((s) => s.exists || !s.metadata.isFromCache)
          .map((s) => s.exists ? UserProfileDto.fromFirestore(s) : null);

  Future<void> saveProfile(UserProfileDto profile) =>
      _doc(profile.id).set(profile.toFirestore(), SetOptions(merge: true));

  Future<String> uploadAvatar(String userId, String filePath) async {
    final extension = filePath.split('.').last.toLowerCase();
    final ref = _storage.ref(
      'users/$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$extension',
    );
    await ref.putFile(
      File(filePath),
      SettableMetadata(
        contentType: 'image/${extension == 'jpg' ? 'jpeg' : extension}',
      ),
    );
    return ref.getDownloadURL();
  }
}
