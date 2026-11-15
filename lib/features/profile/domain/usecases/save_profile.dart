import 'package:spotshare/features/profile/domain/entities/user_profile.dart';
import 'package:spotshare/features/profile/domain/repositories/profile_repository.dart';

class SaveProfile {
  const SaveProfile(this._repository);

  final ProfileRepository _repository;

  Future<void> call(UserProfile profile, {String? avatarPath}) =>
      _repository.saveProfile(
        profile.copyWith(
          displayName: profile.displayName.trim(),
          bio: profile.bio.trim(),
        ),
        avatarPath: avatarPath,
      );
}
