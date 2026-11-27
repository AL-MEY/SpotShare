import 'package:spotshare/features/spot/domain/entities/rating.dart';

abstract interface class RatingRepository {
  Stream<Rating?> watchMyRating({
    required String spotId,
    required String userId,
  });

  Future<void> rate({
    required String spotId,
    required String userId,
    required Rating rating,
  });
}
