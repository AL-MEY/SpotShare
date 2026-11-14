import 'package:spotshare/features/profile/domain/entities/user_profile.dart';

abstract interface class ProfileRepository {
  Stream<UserProfile?> watchProfile(String userId);

  Future<void> saveProfile(UserProfile profile, {String? avatarPath});
}
