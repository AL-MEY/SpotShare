import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotshare/features/spot/domain/entities/rating.dart';
import 'package:spotshare/features/spot/domain/repositories/rating_repository.dart';
import 'package:spotshare/features/spot/domain/usecases/rate_spot.dart';

class _MockRatingRepository extends Mock implements RatingRepository {}

void main() {
  setUpAll(() => registerFallbackValue(Rating(1)));

  test('RateSpot transmet la note au repository', () async {
    final repository = _MockRatingRepository();
    when(
      () => repository.rate(
        spotId: any(named: 'spotId'),
        userId: any(named: 'userId'),
        rating: any(named: 'rating'),
      ),
    ).thenAnswer((_) async {});

    await RateSpot(repository)(spotId: 's1', userId: 'u1', rating: Rating(4));

    verify(() => repository.rate(spotId: 's1', userId: 'u1', rating: Rating(4)))
        .called(1);
  });
}
