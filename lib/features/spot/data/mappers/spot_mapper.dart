import 'package:spotshare/features/spot/data/models/spot_dto.dart';
import 'package:spotshare/features/spot/domain/entities/geo_position.dart';
import 'package:spotshare/features/spot/domain/entities/spot.dart';
import 'package:spotshare/features/spot/domain/entities/spot_category.dart';
import 'package:spotshare/features/spot/domain/entities/spot_media.dart';

extension SpotDtoMapper on SpotDto {
  Spot toEntity() => Spot(
    id: id,
    title: title,
    description: description,
    category: SpotCategory.values.firstWhere(
      (c) => c.name == category,
      orElse: () => SpotCategory.other,
    ),
    address: address,
    location: GeoPosition(
      latitude: location.latitude,
      longitude: location.longitude,
    ),
    media: [for (final m in media) ?_mediaToEntity(m)],
    tags: tags,
    authorId: authorId,
    createdAt: createdAt,
    averageRating: averageRating,
    ratingCount: ratingCount,
    commentCount: commentCount,
  );
}

// Un média mal formé est ignoré plutôt que de casser tout le spot.
SpotMedia? _mediaToEntity(SpotMediaDto dto) => switch (dto) {
  SpotMediaDto(type: 'photo') => SpotPhoto(url: dto.url),
  SpotMediaDto(type: 'video', :final thumbnailUrl?, :final durationMs?) =>
    SpotVideo(
      url: dto.url,
      thumbnailUrl: thumbnailUrl,
      duration: Duration(milliseconds: durationMs),
    ),
  _ => null,
};
