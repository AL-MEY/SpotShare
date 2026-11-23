import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/features/spot/domain/entities/spot_media.dart';

void main() {
  test('la prévisualisation d’une photo est son url', () {
    const media = SpotPhoto(url: 'https://x/photo.jpg');
    expect(media.previewUrl, 'https://x/photo.jpg');
  });

  test('la prévisualisation d’une vidéo est sa vignette', () {
    const media = SpotVideo(
      url: 'https://x/video.mp4',
      thumbnailUrl: 'https://x/thumb.jpg',
      duration: Duration(seconds: 12),
    );
    expect(media.previewUrl, 'https://x/thumb.jpg');
  });
}
