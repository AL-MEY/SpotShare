import 'dart:async';

import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/features/spot/domain/entities/rating.dart';
import 'package:spotshare/features/spot/domain/repositories/rating_repository.dart';

class FakeRatingRepository implements RatingRepository {
  FakeRatingRepository([this._rating]);

  Rating? _rating;
  Failure? failure;
  Completer<void>? pending;
  final rated = <Rating>[];
  final _controller = StreamController<Rating?>.broadcast();

  Future<void> dispose() => _controller.close();

  void emit(Rating? rating) {
    _rating = rating;
    _controller.add(rating);
  }

  @override
  Stream<Rating?> watchMyRating({
    required String spotId,
    required String userId,
  }) async* {
    final failure = this.failure;
    if (failure != null) throw failure;
    yield _rating;
    yield* _controller.stream;
  }

  @override
  Future<void> rate({
    required String spotId,
    required String userId,
    required Rating rating,
  }) async {
    rated.add(rating);
    // Imite la compensation de latence de Firestore.
    emit(rating);
    final pending = this.pending;
    if (pending != null) await pending.future;
    final failure = this.failure;
    if (failure != null) throw failure;
  }
}
