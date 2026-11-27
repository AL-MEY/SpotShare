import 'package:spotshare/features/spot/domain/entities/rating.dart';
import 'package:spotshare/features/spot/domain/repositories/rating_repository.dart';

class RateSpot {
  const RateSpot(this._repository);

  final RatingRepository _repository;

  Future<void> call({
    required String spotId,
    required String userId,
    required Rating rating,
  }) => _repository.rate(spotId: spotId, userId: userId, rating: rating);
}
