import 'package:cloud_firestore/cloud_firestore.dart';

class SpotMediaDto {
  const SpotMediaDto({
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.durationMs,
  });

  factory SpotMediaDto.fromMap(Map<String, dynamic> map) => SpotMediaDto(
    type: map['type'] as String,
    url: map['url'] as String,
    thumbnailUrl: map['thumbnailUrl'] as String?,
    durationMs: (map['durationMs'] as num?)?.toInt(),
  );

  final String type;
  final String url;
  final String? thumbnailUrl;
  final int? durationMs;
}

class SpotDto {
  const SpotDto({
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

  factory SpotDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return SpotDto(
      id: snapshot.id,
      title: data['title'] as String,
      description: data['description'] as String,
      category: data['category'] as String,
      address: data['address'] as String,
      location: data['location'] as GeoPoint,
      media: [
        for (final m in data['media'] as List<dynamic>? ?? const [])
          SpotMediaDto.fromMap(Map<String, dynamic>.from(m as Map)),
      ],
      tags: List<String>.from(data['tags'] as List<dynamic>? ?? const []),
      authorId: data['authorId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0,
      ratingCount: (data['ratingCount'] as num?)?.toInt() ?? 0,
      commentCount: (data['commentCount'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String title;
  final String description;
  final String category;
  final String address;
  final GeoPoint location;
  final List<SpotMediaDto> media;
  final List<String> tags;
  final String authorId;
  final DateTime createdAt;
  final double averageRating;
  final int ratingCount;
  final int commentCount;
}
