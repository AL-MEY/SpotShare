import 'package:spotshare/features/spot/domain/entities/geo_position.dart';
import 'package:spotshare/features/spot/domain/entities/spot_category.dart';
import 'package:spotshare/features/spot/domain/entities/spot_media.dart';

class Spot {
  const Spot({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.address,
    required this.location,
    required this.media,
    required this.tags,
    required this.authorId,
    required this.createdAt,
    required this.averageRating,
    required this.ratingCount,
    required this.commentCount,
  });

  static const titleMinLength = 3;
  static const titleMaxLength = 80;
  static const descriptionMaxLength = 2000;
  static const addressMaxLength = 200;
  static const maxMedia = 10;
  static const maxTags = 10;
  static const tagMaxLength = 24;

  final String id;
  final String title;
  final String description;
  final SpotCategory category;
  final String address;
  final GeoPosition location;
  final List<SpotMedia> media;
  final List<String> tags;
  final String authorId;
  final DateTime createdAt;
  final double averageRating;
  final int ratingCount;
  final int commentCount;

  Spot copyWith({double? averageRating, int? ratingCount, int? commentCount}) =>
      Spot(
        id: id,
        title: title,
        description: description,
        category: category,
        address: address,
        location: location,
        media: media,
        tags: tags,
        authorId: authorId,
        createdAt: createdAt,
        averageRating: averageRating ?? this.averageRating,
        ratingCount: ratingCount ?? this.ratingCount,
        commentCount: commentCount ?? this.commentCount,
      );

  String? get coverImageUrl => media.isEmpty ? null : media.first.previewUrl;

  @override
  bool operator ==(Object other) =>
      other is Spot &&
      other.id == id &&
      other.title == title &&
      other.description == description &&
      other.category == category &&
      other.address == address &&
      other.location == location &&
      _listEquals(other.media, media) &&
      _listEquals(other.tags, tags) &&
      other.authorId == authorId &&
      other.createdAt == createdAt &&
      other.averageRating == averageRating &&
      other.ratingCount == ratingCount &&
      other.commentCount == commentCount;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    category,
    address,
    location,
    Object.hashAll(media),
    Object.hashAll(tags),
    authorId,
    createdAt,
    averageRating,
    ratingCount,
    commentCount,
  );
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
