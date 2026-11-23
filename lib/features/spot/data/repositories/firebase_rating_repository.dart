import 'package:spotshare/core/error/firebase_failure.dart';
import 'package:spotshare/features/spot/data/datasources/rating_remote_data_source.dart';
import 'package:spotshare/features/spot/domain/entities/rating.dart';
import 'package:spotshare/features/spot/domain/repositories/rating_repository.dart';

class FirebaseRatingRepository implements RatingRepository {
  const FirebaseRatingRepository(this._remote);

  final RatingRemoteDataSource _remote;

  @override
  Stream<Rating?> watchMyRating({
    required String spotId,
    required String userId,
  }) => _remote
      .watchRating(spotId, userId)
      .map(_toRating)
      .handleError((Object e) => throw failureFrom(e));

  @override
  Future<void> rate({
    required String spotId,
    required String userId,
    required Rating rating,
  }) async {
    try {
      await _remote.setRating(spotId, userId, rating.value);
    } on Object catch (e) {
      throw failureFrom(e);
    }
  }

  // Valeur hors 1–5 : traitée comme absente plutôt qu'en erreur.
  Rating? _toRating(int? value) =>
      value != null && value >= Rating.min && value <= Rating.max
      ? Rating(value)
      : null;
}
