import 'dart:async';
import 'dart:ui';

import 'package:video_player/video_player.dart';

// Contrôleur sans lecteur natif : l'initialisation se termine à la demande.
class FakeVideoPlayerController extends VideoPlayerController {
  FakeVideoPlayerController() : super.networkUrl(Uri.parse('https://fake'));

  final _initialized = Completer<void>();

  void completeInitialization() {
    value = value.copyWith(
      isInitialized: true,
      duration: const Duration(seconds: 12),
      size: const Size(16, 9),
    );
    _initialized.complete();
  }

  @override
  Future<void> initialize() => _initialized.future;

  @override
  Future<void> play() async => value = value.copyWith(isPlaying: true);

  @override
  Future<void> pause() async => value = value.copyWith(isPlaying: false);

  @override
  Future<void> setVolume(double volume) async =>
      value = value.copyWith(volume: volume);
}
