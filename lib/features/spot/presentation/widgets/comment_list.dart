import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/error/failure_message.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/core/widgets/error_bottom_sheet.dart';
import 'package:spotshare/features/spot/domain/entities/spot_comment.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/features/spot/presentation/widgets/comment_tile.dart';
import 'package:spotshare/i18n/strings.g.dart';

class CommentList extends ConsumerStatefulWidget {
  const CommentList({super.key, required this.spotId});

  final String spotId;

  @override
  ConsumerState<CommentList> createState() => _CommentListState();
}

class _CommentListState extends ConsumerState<CommentList> {
  // null tant que la première liste n'est pas arrivée.
  Set<String>? _seen;
  final _appearing = <String>{};
  int _limit = 0;

  // Seuls les ids absents de l'émission précédente, à limite égale, s'animent.
  void _track(List<SpotComment> list, int limit) {
    final ids = list.map((c) => c.id);
    final seen = _seen;
    if (seen == null || limit != _limit) {
      _appearing.clear();
      _seen = ids.toSet();
      _limit = limit;
      return;
    }
    for (final id in ids) {
      if (seen.add(id)) _appearing.add(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spotId = widget.spotId;
    final theme = context.appTheme;
    final t = context.t;
    final comments = ref.watch(commentsProvider(spotId));
    final limit = ref.watch(commentsLimitProvider(spotId));
    // Une seule écoute ici : sinon chaque tuile ouvrirait sa propre bottom sheet.
    ref.listen(deleteCommentControllerProvider, (_, next) {
      final error = next.error;
      if (error is Failure) showErrorBottomSheet(context, error);
    });

    return comments.when(
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => SliverToBoxAdapter(
        child: Text(
          (error is Failure ? error : const UnknownFailure()).message(t),
          style: theme.textStyles.b2,
        ),
      ),
      data: (list) {
        _track(list, limit);
        if (list.isEmpty) {
          return SliverToBoxAdapter(
            child: Text(t.spot.comments.none, style: theme.textStyles.b1),
          );
        }
        final hasMore = list.length >= limit;
        return SliverList.builder(
          itemCount: list.length + (hasMore ? 1 : 0),
          findChildIndexCallback: (key) {
            final id = (key as ValueKey<String>).value;
            final i = list.indexWhere((c) => c.id == id);
            return i < 0 ? null : i;
          },
          itemBuilder: (context, i) {
            if (i == list.length) {
              return Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: ref
                      .read(commentsLimitProvider(spotId).notifier)
                      .showMore,
                  child: Text(t.spot.comments.showMore),
                ),
              );
            }
            final comment = list[i];
            final tile = CommentTile(comment: comment, spotId: spotId);
            if (!_appearing.contains(comment.id)) {
              return KeyedSubtree(key: ValueKey(comment.id), child: tile);
            }
            return TweenAnimationBuilder<double>(
              key: ValueKey(comment.id),
              onEnd: () => _appearing.remove(comment.id),
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 250),
              builder: (_, value, child) => Align(
                alignment: Alignment.topCenter,
                heightFactor: value,
                child: Opacity(opacity: value, child: child),
              ),
              child: tile,
            );
          },
        );
      },
    );
  }
}
