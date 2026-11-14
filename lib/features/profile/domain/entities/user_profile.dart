class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    this.bio = '',
    this.avatarUrl,
  });

  static const displayNameMinLength = 2;
  static const displayNameMaxLength = 30;
  static const bioMaxLength = 160;

  final String id;
  final String displayName;
  final String bio;
  final String? avatarUrl;

  UserProfile copyWith({String? displayName, String? bio, String? avatarUrl}) =>
      UserProfile(
        id: id,
        displayName: displayName ?? this.displayName,
        bio: bio ?? this.bio,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );

  @override
  bool operator ==(Object other) =>
      other is UserProfile &&
      other.id == id &&
      other.displayName == displayName &&
      other.bio == bio &&
      other.avatarUrl == avatarUrl;

  @override
  int get hashCode => Object.hash(id, displayName, bio, avatarUrl);
}
