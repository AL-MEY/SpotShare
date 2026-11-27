import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/network/connectivity_provider.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/core/widgets/error_bottom_sheet.dart';
import 'package:spotshare/core/widgets/rating_stars.dart';
import 'package:spotshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:spotshare/features/spot/domain/entities/rating.dart';
import 'package:spotshare/features/spot/domain/entities/spot.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/i18n/strings.g.dart';

class MyRatingStars extends ConsumerWidget {
  const MyRatingStars({super.key, required this.spot});

  final Spot spot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t.spot;
    final theme = context.appTheme;
    final userId = ref.watch(currentUserIdProvider);
    ref.listen(rateSpotControllerProvider, (_, next) {
      final error = next.error;
      if (error is Failure) showErrorBottomSheet(context, error);
    });

    if (userId != null && spot.authorId == userId) {
      return Text(t.ownSpot, style: theme.textStyles.b1);
    }
    final rating = ref.watch(myRatingProvider(spot.id)).value;
    // Chargement ou erreur de connectivité : on ne bloque pas la notation.
    final online = ref.watch(isOnlineProvider).value ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.yourRating, style: theme.textStyles.b1),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: RatingStars(
            key: ValueKey(rating?.value ?? 0),
            value: (rating?.value ?? 0).toDouble(),
            onChanged: online && userId != null
                ? (n) => _rate(ref, userId, n)
                : null,
            semanticLabel: (n) => t.rateTooltip(n: n),
          ),
        ),
        if (!online) Text(t.offline, style: theme.textStyles.b2),
      ],
    );
  }

  void _rate(WidgetRef ref, String userId, int n) {
    ref
        .read(rateSpotControllerProvider.notifier)
        .submit(
          () => ref.read(rateSpotProvider)(
            spotId: spot.id,
            userId: userId,
            rating: Rating(n),
          ),
        );
  }
}
