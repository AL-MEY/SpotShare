import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/error/failure_message.dart';
import 'package:spotshare/core/router/app_router.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_back_button.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_media_pager.dart';
import 'package:spotshare/i18n/strings.g.dart';

class SpotMediaViewerPage extends ConsumerWidget {
  const SpotMediaViewerPage({
    super.key,
    required this.spotId,
    required this.initialIndex,
  });

  final String spotId;
  final int initialIndex;

  Failure _failure(Object error) =>
      error is Failure ? error : const UnknownFailure();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final colors = theme.colors;
    final t = context.t;
    final state = ref.watch(spotContentProvider(spotId));
    return Scaffold(
      backgroundColor: colors.inverse,
      body: Stack(
        fit: StackFit.expand,
        children: [
          switch (state) {
            AsyncData(:final value) when value.media.isNotEmpty =>
              SpotMediaPager(spot: value, initialIndex: initialIndex),
            AsyncError(:final error) => Center(
              child: Padding(
                padding: EdgeInsets.all(theme.spacing.spacingL),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: theme.spacing.spacingS,
                  children: [
                    Text(
                      _failure(error).title(t),
                      style: theme.textStyles.h3.copyWith(
                        color: colors.onInverse,
                      ),
                    ),
                    Text(
                      _failure(error).message(t),
                      textAlign: TextAlign.center,
                      style: theme.textStyles.b2.copyWith(
                        color: colors.onInverse,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _ => Center(
              child: CircularProgressIndicator(color: colors.onInverse),
            ),
          },
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: SpotBackButton(
                onMedia: true,
                closeTooltip: t.spot.media.close,
                fallbackLocation: AppRoutes.spotDetail(spotId),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
