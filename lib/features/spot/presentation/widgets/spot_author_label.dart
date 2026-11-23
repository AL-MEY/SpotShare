import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/features/spot/presentation/widgets/author_avatar.dart';
import 'package:spotshare/features/spot/presentation/widgets/author_name.dart';
import 'package:spotshare/i18n/strings.g.dart';

class SpotAuthorLabel extends ConsumerWidget {
  const SpotAuthorLabel({super.key, required this.authorId});

  final String authorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final state = ref.watch(spotAuthorProvider(authorId));
    final author = state.value;
    final name = authorNameOf(author);
    final t = context.t.spot;
    final label = switch (name) {
      _ when name.isNotEmpty => t.by(name: name),
      _ when isAuthorPending(state) => '',
      _ => t.unknownAuthor,
    };
    return Row(
      children: [
        AuthorAvatar(
          avatarUrl: author?.avatarUrl,
          size: theme.spacing.spacingXl,
        ),
        SizedBox(width: theme.spacing.spacingS),
        Expanded(
          child: Text(
            label,
            style: theme.textStyles.b2.copyWith(
              color: theme.colors.foregroundMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
