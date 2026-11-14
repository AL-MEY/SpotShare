import 'package:spotshare/features/profile/data/models/user_profile_dto.dart';
import 'package:spotshare/features/profile/domain/entities/user_profile.dart';

extension UserProfileDtoMapper on UserProfileDto {
  UserProfile toEntity() => UserProfile(
    id: id,
    displayName: displayName,
    bio: bio,
    avatarUrl: avatarUrl,
  );
}

extension UserProfileMapper on UserProfile {
  UserProfileDto toDto() => UserProfileDto(
    id: id,
    displayName: displayName,
    bio: bio,
    avatarUrl: avatarUrl,
  );
}
