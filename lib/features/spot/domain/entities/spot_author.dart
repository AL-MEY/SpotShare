class SpotAuthor {
  const SpotAuthor({
    required this.id,
    required this.displayName,
    this.avatarUrl,
  });

  final String id;
  final String displayName;
  final String? avatarUrl;

  @override
  bool operator ==(Object other) =>
      other is SpotAuthor &&
      other.id == id &&
      other.displayName == displayName &&
      other.avatarUrl == avatarUrl;

  @override
  int get hashCode => Object.hash(id, displayName, avatarUrl);
}
