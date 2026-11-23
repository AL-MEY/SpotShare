import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:spotshare/features/spot/domain/entities/rating.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';

import '../../../../helpers/fake_comment_repository.dart';
import '../../../../helpers/fake_rating_repository.dart';
import '../../../../helpers/fake_spot_repository.dart';
import '../../../../helpers/spot_fixtures.dart';

void main() {
  late FakeSpotRepository spots;
  late FakeRatingRepository ratings;
  late FakeCommentRepository comments;

  setUp(() {
    spots = FakeSpotRepository(spot: buildSpot());
    ratings = FakeRatingRepository();
    comments = FakeCommentRepository();
  });

  tearDown(() async {
    await spots.dispose();
    await ratings.dispose();
    await comments.dispose();
  });

  ProviderContainer makeContainer({String? userId = 'u1'}) {
    final container = ProviderContainer(
      overrides: [
        spotRepositoryProvider.overrideWithValue(spots),
        ratingRepositoryProvider.overrideWithValue(ratings),
        commentRepositoryProvider.overrideWithValue(comments),
        currentUserIdProvider.overrideWithValue(userId),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('spotProvider passe de loading à data', () async {
    final container = makeContainer();
    container.listen(spotProvider(spotId), (_, _) {});

    expect(container.read(spotProvider(spotId)), isA<AsyncLoading<Object?>>());
    final spot = await container.read(spotProvider(spotId).future);

    expect(spot.id, spotId);
  });

  test('spotProvider passe en erreur avec la Failure du repository', () async {
    spots.failure = const NetworkFailure();
    final container = makeContainer();
    container.listen(spotProvider(spotId), (_, _) {});

    await expectLater(
      container.read(spotProvider(spotId).future),
      throwsA(isA<NetworkFailure>()),
    );
  });

  test('recentSpotsProvider demande les 20 spots les plus récents', () async {
    final container = makeContainer();
    container.listen(recentSpotsProvider, (_, _) {});
    await container.read(recentSpotsProvider.future);

    expect(spots.requestedRecentLimits, [20]);
  });

  test('myRatingProvider vaut null sans utilisateur connecté', () async {
    final container = makeContainer(userId: null);
    container.listen(myRatingProvider(spotId), (_, _) {});

    expect(await container.read(myRatingProvider(spotId).future), isNull);
  });

  test(
    'commentsProvider charge 20 commentaires puis 40 après showMore',
    () async {
      final container = makeContainer();
      container.listen(commentsProvider(spotId), (_, _) {});
      await container.read(commentsProvider(spotId).future);

      container.read(commentsLimitProvider(spotId).notifier).showMore();
      await pumpEventQueue();
      await container.read(commentsProvider(spotId).future);

      expect(comments.requestedLimits, [20, 40]);
    },
  );

  test(
    'rateSpotControllerProvider passe en erreur quand la note est refusée',
    () async {
      ratings.failure = const PermissionFailure();
      final container = makeContainer();
      container.listen(rateSpotControllerProvider, (_, _) {});

      await container
          .read(rateSpotControllerProvider.notifier)
          .submit(
            () => container
                .read(rateSpotProvider)
                .call(spotId: spotId, userId: 'u1', rating: Rating(4)),
          );

      final state = container.read(rateSpotControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<PermissionFailure>());
    },
  );
}
