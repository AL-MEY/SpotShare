import 'package:spotshare/features/spot/domain/entities/spot.dart';

abstract interface class SpotRepository {
  Stream<Spot> watchSpot(String spotId);

  Stream<List<Spot>> watchRecentSpots({int limit = 20});
}
