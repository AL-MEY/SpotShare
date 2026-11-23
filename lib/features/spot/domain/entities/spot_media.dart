sealed class SpotMedia {
  const SpotMedia({required this.url});

  final String url;

  String get previewUrl;
}

final class SpotPhoto extends SpotMedia {
  const SpotPhoto({required super.url});

  @override
  String get previewUrl => url;

  @override
  bool operator ==(Object other) => other is SpotPhoto && other.url == url;

  @override
  int get hashCode => Object.hash(SpotPhoto, url);
}

final class SpotVideo extends SpotMedia {
  const SpotVideo({
    required super.url,
    required this.thumbnailUrl,
    required this.duration,
  });

  static const maxDuration = Duration(seconds: 60);

  final String thumbnailUrl;
  final Duration duration;

  @override
  String get previewUrl => thumbnailUrl;

  @override
  bool operator ==(Object other) =>
      other is SpotVideo &&
      other.url == url &&
      other.thumbnailUrl == thumbnailUrl &&
      other.duration == duration;

  @override
  int get hashCode => Object.hash(SpotVideo, url, thumbnailUrl, duration);
}
