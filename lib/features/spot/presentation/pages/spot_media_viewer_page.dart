import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appTheme.colors;
    final spot = ref.watch(spotContentProvider(spotId)).value;
    return Scaffold(
      backgroundColor: colors.inverse,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (spot == null || spot.media.isEmpty)
            Center(child: CircularProgressIndicator(color: colors.onInverse))
          else
            SpotMediaPager(spot: spot, initialIndex: initialIndex),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                tooltip: context.t.spot.media.close,
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: colors.mediaButton,
                  foregroundColor: colors.onMedia,
                ),
                onPressed: () => context.pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
