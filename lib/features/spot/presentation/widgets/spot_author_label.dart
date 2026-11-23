import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/features/spot/presentation/widgets/author_avatar.dart';
import 'package:spotshare/i18n/strings.g.dart';

class SpotAuthorLabel extends ConsumerWidget {
  const SpotAuthorLabel({super.key, required this.authorId});

  final String authorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final author = ref.watch(spotAuthorProvider(authorId)).value;
    final name = author?.displayName.trim() ?? '';
    final t = context.t.spot;
    return Row(
      children: [
        AuthorAvatar(
          avatarUrl: author?.avatarUrl,
          size: theme.spacing.spacingXl,
        ),
        SizedBox(width: theme.spacing.spacingS),
        Expanded(
          child: Text(
            name.isEmpty ? t.unknownAuthor : t.by(name: name),
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
