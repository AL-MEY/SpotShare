import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotshare/features/profile/presentation/providers/profile_providers.dart';

class _MockImagePicker extends Mock implements ImagePicker {}

void main() {
  late _MockImagePicker picker;
  late ProviderContainer container;

  setUp(() {
    picker = _MockImagePicker();
    container = ProviderContainer(
      overrides: [imagePickerProvider.overrideWithValue(picker)],
    );
    addTearDown(container.dispose);
    container.listen(pickedAvatarProvider, (_, _) {});
  });

  void whenPicked(XFile? file) => when(
    () => picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: any(named: 'maxWidth'),
      maxHeight: any(named: 'maxHeight'),
      imageQuality: any(named: 'imageQuality'),
    ),
  ).thenAnswer((_) async => file);

  test('retient le chemin de l’image choisie', () async {
    whenPicked(XFile('/tmp/a.jpg'));

    await container
        .read(pickedAvatarProvider.notifier)
        .pick(ImageSource.gallery);

    expect(container.read(pickedAvatarProvider), '/tmp/a.jpg');
  });

  test('ne change rien quand l’utilisateur annule', () async {
    whenPicked(null);

    await container
        .read(pickedAvatarProvider.notifier)
        .pick(ImageSource.gallery);

    expect(container.read(pickedAvatarProvider), isNull);
  });
}
