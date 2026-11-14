import 'dart:developer';

import 'package:spotshare/core/error/firebase_failure.dart';
import 'package:spotshare/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:spotshare/features/profile/data/mappers/user_profile_mapper.dart';
import 'package:spotshare/features/profile/domain/entities/user_profile.dart';
import 'package:spotshare/features/profile/domain/repositories/profile_repository.dart';

class FirebaseProfileRepository implements ProfileRepository {
  const FirebaseProfileRepository(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Stream<UserProfile?> watchProfile(String userId) => _remote
      .watchProfile(userId)
      .map((dto) => dto?.toEntity())
      .handleError((Object e) => throw failureFrom(e));

  @override
  Future<void> saveProfile(UserProfile profile, {String? avatarPath}) async {
    final previousAvatar = profile.avatarUrl;
    try {
      final toSave = avatarPath == null
          ? profile
          : profile.copyWith(
              avatarUrl: await _remote.uploadAvatar(profile.id, avatarPath),
            );
      await _remote.saveProfile(toSave.toDto());
      if (avatarPath != null && previousAvatar != null) {
        await _deleteQuietly(previousAvatar);
      }
    } catch (e) {
      throw failureFrom(e);
    }
  }

  Future<void> _deleteQuietly(String url) async {
    try {
      await _remote.deleteFile(url);
    } catch (e) {
      log('Old avatar not deleted', name: 'profile', error: e);
    }
  }
}
