import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/i18n/strings.g.dart';

class CommentsTitle extends ConsumerWidget {
  const CommentsTitle({super.key, required this.spotId});

  final String spotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(
      spotProvider(spotId).select((s) => s.value?.commentCount ?? 0),
    );
    return Text(
      context.t.spot.comments.title(n: count),
      style: context.appTheme.textStyles.h3,
    );
  }
}
