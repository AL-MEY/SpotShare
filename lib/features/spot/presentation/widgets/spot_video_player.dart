import 'package:flutter/material.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/spot/domain/entities/spot_media.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_media_thumbnail.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_video_controls.dart';
import 'package:spotshare/i18n/strings.g.dart';
import 'package:video_player/video_player.dart';

class SpotVideoPlayer extends StatefulWidget {
  const SpotVideoPlayer({
    super.key,
    required this.video,
    required this.isActive,
  });

  final SpotVideo video;
  final bool isActive;

  @override
  State<SpotVideoPlayer> createState() => _SpotVideoPlayerState();
}

class _SpotVideoPlayerState extends State<SpotVideoPlayer> {
  late final VideoPlayerController _controller =
      VideoPlayerController.networkUrl(Uri.parse(widget.video.url));
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onValue);
    _controller.initialize().catchError((Object _) {
      if (mounted) setState(() => _failed = true);
    });
  }

  void _onValue() {
    if (_controller.value.hasError && !_failed && mounted) {
      setState(() => _failed = true);
    }
  }

  @override
  void didUpdateWidget(SpotVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Une vidéo hors page ne doit jamais continuer à jouer.
    if (oldWidget.isActive && !widget.isActive) _controller.pause();
  }

  @override
  void dispose() {
    _controller.removeListener(_onValue);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final width = MediaQuery.sizeOf(context).width;
    final thumbnail = SpotMediaThumbnail(media: widget.video, width: width);
    if (_failed) {
      return Stack(
        fit: StackFit.expand,
        children: [
          thumbnail,
          Center(
            child: Text(
              context.t.spot.media.videoError,
              textAlign: TextAlign.center,
              style: theme.textStyles.b2.copyWith(color: theme.colors.onMedia),
            ),
          ),
        ],
      );
    }
    if (!_controller.value.isInitialized) return thumbnail;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
          SpotVideoControls(controller: _controller),
        ],
      ),
    );
  }
}
