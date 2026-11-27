import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/error/firebase_failure.dart';
import 'package:spotshare/features/spot/data/datasources/spot_remote_data_source.dart';
import 'package:spotshare/features/spot/data/mappers/spot_mapper.dart';
import 'package:spotshare/features/spot/domain/entities/spot.dart';
import 'package:spotshare/features/spot/domain/repositories/spot_repository.dart';

class FirebaseSpotRepository implements SpotRepository {
  const FirebaseSpotRepository(this._remote);

  final SpotRemoteDataSource _remote;

  @override
  Stream<Spot> watchSpot(String spotId) => _remote
      .watchSpot(spotId)
      .map((doc) {
        final dto = doc.dto;
        if (dto != null) return dto.toEntity();
        // Absent du cache : on ne sait pas encore s'il existe, donc réseau.
        throw doc.isFromCache
            ? const NetworkFailure()
            : const NotFoundFailure();
      })
      .handleError((Object e) => throw failureFrom(e));

  @override
  Stream<List<Spot>> watchRecentSpots({int limit = 20}) => _remote
      .watchRecentSpots(limit)
      .map((dtos) => dtos.map((d) => d.toEntity()).toList())
      .handleError((Object e) => throw failureFrom(e));
}
