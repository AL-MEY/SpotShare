import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/core/widgets/rating_stars.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/i18n/strings.g.dart';

class SpotRatingSummary extends ConsumerWidget {
  const SpotRatingSummary({super.key, required this.spotId});

  final String spotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final (average, count) = ref.watch(
      spotProvider(spotId)
          .select((s) => (s.value?.averageRating, s.value?.ratingCount)),
    );
    final t = context.t.spot;
    final style = theme.textStyles.b2.copyWith(
      color: theme.colors.foregroundMuted,
    );
    if (count == null || count == 0) {
      return Text(t.noRating, style: style);
    }
    final locale = Localizations.localeOf(context).toLanguageTag();
    final format = NumberFormat.decimalPattern(locale)
      ..minimumFractionDigits = 1
      ..maximumFractionDigits = 1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RatingStars(value: average ?? 0, size: theme.spacing.spacingM),
        SizedBox(width: theme.spacing.spacingXs),
        Text(
          '${format.format(average ?? 0)} (${t.ratingCount(n: count)})',
          style: style,
        ),
      ],
    );
  }
}
