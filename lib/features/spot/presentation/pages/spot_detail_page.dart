import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_detail_layout.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_detail_skeleton.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_load_error.dart';

class SpotDetailPage extends ConsumerWidget {
  const SpotDetailPage({super.key, required this.spotId});

  final String spotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(spotContentProvider(spotId));
    return Scaffold(
      // Retour seulement hors données : la fiche aura sa propre barre.
      appBar: state is AsyncData
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              leading: BackButton(
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRoutes.home),
              ),
            ),
      body: AnimatedSwitcher(
        duration: kThemeAnimationDuration,
        child: switch (state) {
          AsyncError(:final error) => SpotLoadError(
            failure: error is Failure ? error : const UnknownFailure(),
            onRetry: () => ref.invalidate(spotProvider(spotId)),
          ),
          AsyncData(:final value) => SpotDetailLayout(spot: value),
          _ => const SpotDetailSkeleton(),
        },
      ),
    );
  }
}
