import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:spotshare/features/spot/domain/entities/spot_comment.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/features/spot/presentation/widgets/author_avatar.dart';
import 'package:spotshare/features/spot/presentation/widgets/author_name.dart';
import 'package:spotshare/features/spot/presentation/widgets/delete_comment_dialog.dart';
import 'package:spotshare/features/spot/presentation/widgets/relative_time.dart';
import 'package:spotshare/i18n/strings.g.dart';

class CommentTile extends ConsumerWidget {
  const CommentTile({super.key, required this.comment, required this.spotId});

  final SpotComment comment;
  final String spotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final t = context.t;
    final author = ref.watch(spotAuthorProvider(comment.authorId)).value;
    final name = authorNameOf(author);
    final isMine = ref.watch(currentUserIdProvider) == comment.authorId;
    final muted = theme.textStyles.b2.copyWith(
      color: theme.colors.foregroundMuted,
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: theme.spacing.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: theme.spacing.spacingS,
        children: [
          AuthorAvatar(
            avatarUrl: author?.avatarUrl,
            size: theme.spacing.spacingXl,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? t.spot.unknownAuthor : name,
                  style: theme.textStyles.b2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  formatRelativeTime(
                    comment.createdAt,
                    DateTime.now(),
                    t,
                    TranslationProvider.of(context).locale.languageCode,
                  ),
                  style: muted,
                ),
                SizedBox(height: theme.spacing.spacing2xs),
                Text(comment.text, style: theme.textStyles.b1),
              ],
            ),
          ),
          if (isMine) _DeleteButton(comment: comment, spotId: spotId),
        ],
      ),
    );
  }
}

class _DeleteButton extends ConsumerWidget {
  const _DeleteButton({required this.comment, required this.spotId});

  final SpotComment comment;
  final String spotId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    if (!await showDeleteCommentDialog(context) || !context.mounted) return;
    unawaited(
      ref
          .read(deleteCommentControllerProvider.notifier)
          .submit(
            () => ref.read(deleteCommentProvider)(
              spotId: spotId,
              commentId: comment.id,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.delete_outline),
      tooltip: context.t.spot.comments.delete,
      onPressed: () => _delete(context, ref),
    );
  }
}
