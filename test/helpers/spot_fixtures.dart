import 'package:spotshare/features/spot/domain/entities/geo_position.dart';
import 'package:spotshare/features/spot/domain/entities/spot.dart';
import 'package:spotshare/features/spot/domain/entities/spot_category.dart';
import 'package:spotshare/features/spot/domain/entities/spot_comment.dart';
import 'package:spotshare/features/spot/domain/entities/spot_media.dart';

const spotId = 's1';

Spot buildSpot({
  String id = spotId,
  String title = 'Café du coin',
  String description = 'Un café tranquille',
  SpotCategory category = SpotCategory.cafe,
  String address = '1 rue de Rivoli, Paris',
  GeoPosition location = const GeoPosition(
    latitude: 48.8566,
    longitude: 2.3522,
  ),
  List<SpotMedia>? media,
  List<String> tags = const ['calme'],
  String authorId = 'author',
  DateTime? createdAt,
  double averageRating = 0,
  int ratingCount = 0,
  int commentCount = 0,
  int favoriteCount = 0,
  String? geohash,
}) => Spot(
  id: id,
  title: title,
  description: description,
  category: category,
  address: address,
  location: location,
  media:
      media ??
      const [
        SpotPhoto(url: 'https://example.com/photo1.jpg'),
        SpotPhoto(url: 'https://example.com/photo2.jpg'),
      ],
  tags: tags,
  authorId: authorId,
  createdAt: createdAt ?? DateTime(2026, 11),
  averageRating: averageRating,
  ratingCount: ratingCount,
  commentCount: commentCount,
  favoriteCount: favoriteCount,
  geohash: geohash,
);

SpotComment buildComment({
  String id = 'c1',
  String authorId = 'author',
  String text = 'Super endroit',
  DateTime? createdAt,
}) => SpotComment(
  id: id,
  authorId: authorId,
  text: text,
  createdAt: createdAt ?? DateTime(2026, 11, 2),
);
