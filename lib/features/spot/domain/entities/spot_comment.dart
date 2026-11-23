class SpotComment {
  const SpotComment({
    required this.id,
    required this.authorId,
    required this.text,
    required this.createdAt,
  });

  static const maxLength = 500;

  final String id;
  final String authorId;
  final String text;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      other is SpotComment &&
      other.id == id &&
      other.authorId == authorId &&
      other.text == text &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(id, authorId, text, createdAt);
}
