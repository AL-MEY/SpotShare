import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/error/failure_message.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/features/spot/presentation/widgets/comment_tile.dart';
import 'package:spotshare/i18n/strings.g.dart';

class CommentList extends ConsumerWidget {
  const CommentList({super.key, required this.spotId});

  final String spotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final t = context.t;
    final comments = ref.watch(commentsProvider(spotId));
    final limit = ref.watch(commentsLimitProvider(spotId));

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
            return TweenAnimationBuilder<double>(
              key: ValueKey(comment.id),
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 250),
              builder: (_, value, child) => Align(
                alignment: Alignment.topCenter,
                heightFactor: value,
                child: Opacity(opacity: value, child: child),
              ),
              child: CommentTile(comment: comment, spotId: spotId),
            );
          },
        );
      },
    );
  }
}
