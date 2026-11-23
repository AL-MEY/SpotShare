import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_detail_layout.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_detail_skeleton.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_load_error.dart';

class SpotDetailPage extends ConsumerWidget {
  const SpotDetailPage({super.key, required this.spotId});

  final String spotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: kThemeAnimationDuration,
        child: switch (ref.watch(spotProvider(spotId))) {
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
