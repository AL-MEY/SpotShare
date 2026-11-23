import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/features/spot/domain/entities/spot.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_back_button.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_detail_layout.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_detail_skeleton.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_load_error.dart';

class SpotDetailPage extends ConsumerWidget {
  const SpotDetailPage({super.key, required this.spotId, this.initialSpot});

  final String spotId;
  final Spot? initialSpot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(spotContentProvider(spotId));
    final initial = initialSpot;
    // Le spot de la liste s'affiche dès la 1re frame : la transition Hero a sa cible.
    final spot = switch (state) {
      AsyncError() => null,
      AsyncData(:final value) => value,
      _ => initial == null ? null : withoutServerFields(initial),
    };
    return Scaffold(
      // Retour seulement hors fiche : la fiche a sa propre barre.
      appBar: spot != null
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              leading: const SpotBackButton(),
            ),
      body: AnimatedSwitcher(
        duration: kThemeAnimationDuration,
        child: switch (state) {
          AsyncError(:final error) => SpotLoadError(
            failure: error is Failure ? error : const UnknownFailure(),
            onRetry: () => ref.invalidate(spotProvider(spotId)),
          ),
          _ when spot != null => SpotDetailLayout(spot: spot),
          // Lien direct sans spot transmis : squelette.
          _ => const SpotDetailSkeleton(),
        },
      ),
    );
  }
}
