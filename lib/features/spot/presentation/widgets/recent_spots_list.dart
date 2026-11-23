import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_list_tile.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_load_error.dart';
import 'package:spotshare/i18n/strings.g.dart';

class RecentSpotsList extends ConsumerWidget {
  const RecentSpotsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t.spot.recent;
    final theme = context.appTheme;
    final recent = ref.watch(recentSpotsProvider);
    return recent.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => SpotLoadError(
        failure: error is Failure ? error : const UnknownFailure(),
        onRetry: () => ref.invalidate(recentSpotsProvider),
      ),
      data: (spots) => ListView(
        padding: EdgeInsets.symmetric(vertical: theme.spacing.spacingS),
        children: [
          Padding(
            padding: EdgeInsets.all(theme.spacing.spacingM),
            child: Text(t.title, style: theme.textStyles.h3),
          ),
          if (spots.isEmpty)
            Padding(
              padding: EdgeInsets.all(theme.spacing.spacingM),
              child: Text(
                t.empty,
                style: theme.textStyles.b2.copyWith(
                  color: theme.colors.foregroundMuted,
                ),
              ),
            )
          else
            for (final spot in spots) SpotListTile(spot: spot),
        ],
      ),
    );
  }
}
