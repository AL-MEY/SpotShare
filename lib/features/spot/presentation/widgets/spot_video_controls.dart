import 'package:flutter/material.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/i18n/strings.g.dart';
import 'package:video_player/video_player.dart';

class SpotVideoControls extends StatelessWidget {
  const SpotVideoControls({super.key, required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = theme.colors;
    final t = context.t;
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) => Stack(
        fit: StackFit.expand,
        children: [
          if (!value.isPlaying)
            Center(
              child: Icon(
                Icons.play_circle_fill,
                size: theme.spacing.spacing4xl,
                color: colors.onMedia,
                semanticLabel: t.spot.media.play,
              ),
            ),
          Positioned(
            left: theme.spacing.spacingM,
            right: theme.spacing.spacingM,
            bottom: theme.spacing.spacing4xl,
            child: Row(
              spacing: theme.spacing.spacingS,
              children: [
                Expanded(
                  child: VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: colors.onMedia,
                      bufferedColor: colors.mediaButton,
                      backgroundColor: colors.mediaButton,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: value.volume == 0
                      ? t.spot.media.unmute
                      : t.spot.media.mute,
                  onPressed: () =>
                      controller.setVolume(value.volume == 0 ? 1 : 0),
                  style: IconButton.styleFrom(
                    backgroundColor: colors.mediaButton,
                  ),
                  icon: Icon(
                    value.volume == 0 ? Icons.volume_off : Icons.volume_up,
                    color: colors.onMedia,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
