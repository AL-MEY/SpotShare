import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/core/providers/submit_controller.dart';
import 'package:spotshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:spotshare/features/spot/data/datasources/comment_remote_data_source.dart';
import 'package:spotshare/features/spot/data/datasources/rating_remote_data_source.dart';
import 'package:spotshare/features/spot/data/datasources/spot_author_remote_data_source.dart';
import 'package:spotshare/features/spot/data/datasources/spot_remote_data_source.dart';
import 'package:spotshare/features/spot/data/repositories/firebase_comment_repository.dart';
import 'package:spotshare/features/spot/data/repositories/firebase_rating_repository.dart';
import 'package:spotshare/features/spot/data/repositories/firebase_spot_author_repository.dart';
import 'package:spotshare/features/spot/data/repositories/firebase_spot_repository.dart';
import 'package:spotshare/features/spot/domain/entities/rating.dart';
import 'package:spotshare/features/spot/domain/entities/spot.dart';
import 'package:spotshare/features/spot/domain/entities/spot_author.dart';
import 'package:spotshare/features/spot/domain/entities/spot_comment.dart';
import 'package:spotshare/features/spot/domain/repositories/comment_repository.dart';
import 'package:spotshare/features/spot/domain/repositories/rating_repository.dart';
import 'package:spotshare/features/spot/domain/repositories/spot_author_repository.dart';
import 'package:spotshare/features/spot/domain/repositories/spot_repository.dart';
import 'package:spotshare/features/spot/domain/usecases/add_comment.dart';
import 'package:spotshare/features/spot/domain/usecases/delete_comment.dart';
import 'package:spotshare/features/spot/domain/usecases/rate_spot.dart';

final spotRepositoryProvider = Provider<SpotRepository>(
  (ref) =>
      FirebaseSpotRepository(SpotRemoteDataSource(FirebaseFirestore.instance)),
);

final ratingRepositoryProvider = Provider<RatingRepository>(
  (ref) => FirebaseRatingRepository(
    RatingRemoteDataSource(FirebaseFirestore.instance),
  ),
);

final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => FirebaseCommentRepository(
    CommentRemoteDataSource(FirebaseFirestore.instance),
  ),
);

final spotAuthorRepositoryProvider = Provider<SpotAuthorRepository>(
  (ref) => FirebaseSpotAuthorRepository(
    SpotAuthorRemoteDataSource(FirebaseFirestore.instance),
  ),
);

final rateSpotProvider = Provider(
  (ref) => RateSpot(ref.watch(ratingRepositoryProvider)),
);

final addCommentProvider = Provider(
  (ref) => AddComment(ref.watch(commentRepositoryProvider)),
);

final deleteCommentProvider = Provider(
  (ref) => DeleteComment(ref.watch(commentRepositoryProvider)),
);

final spotProvider = StreamProvider.autoDispose.family<Spot, String>(
  (ref, spotId) => ref.watch(spotRepositoryProvider).watchSpot(spotId),
  retry: (_, _) => null,
);

// Compteurs remis à 0 : la page ne se reconstruit pas quand seule la note ou un compteur change.
final spotContentProvider = Provider.autoDispose
    .family<AsyncValue<Spot>, String>(
      (ref, spotId) => ref.watch(
        spotProvider(spotId).select(
          (s) => s.whenData(
            (spot) => spot.copyWith(
              averageRating: 0,
              ratingCount: 0,
              commentCount: 0,
            ),
          ),
        ),
      ),
    );

final recentSpotsProvider = StreamProvider.autoDispose<List<Spot>>(
  (ref) => ref.watch(spotRepositoryProvider).watchRecentSpots(),
  retry: (_, _) => null,
);

final spotAuthorProvider = StreamProvider.autoDispose
    .family<SpotAuthor?, String>(
      (ref, userId) =>
          ref.watch(spotAuthorRepositoryProvider).watchAuthor(userId),
      retry: (_, _) => null,
    );

// Firestore émet l'écriture locale tout de suite (latency compensation) : pas d'état optimiste à gérer ici.
final myRatingProvider = StreamProvider.autoDispose.family<Rating?, String>((
  ref,
  spotId,
) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(null);
  return ref
      .watch(ratingRepositoryProvider)
      .watchMyRating(spotId: spotId, userId: userId);
}, retry: (_, _) => null);

final commentsLimitProvider = NotifierProvider.autoDispose
    .family<CommentsLimit, int, String>(CommentsLimit.new);

class CommentsLimit extends Notifier<int> {
  CommentsLimit(this.spotId);

  static const pageSize = 20;

  final String spotId;

  @override
  int build() => pageSize;

  void showMore() => state += pageSize;
}

final commentsProvider = StreamProvider.autoDispose
    .family<List<SpotComment>, String>((ref, spotId) {
      final limit = ref.watch(commentsLimitProvider(spotId));
      return ref
          .watch(commentRepositoryProvider)
          .watchComments(spotId, limit: limit);
    }, retry: (_, _) => null);

final rateSpotControllerProvider =
    AsyncNotifierProvider.autoDispose<SubmitController, void>(
      SubmitController.new,
    );

final commentComposerControllerProvider =
    AsyncNotifierProvider.autoDispose<SubmitController, void>(
      SubmitController.new,
    );

final deleteCommentControllerProvider =
    AsyncNotifierProvider.autoDispose<SubmitController, void>(
      SubmitController.new,
    );
