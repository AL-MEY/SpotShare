import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotshare/features/profile/presentation/providers/profile_providers.dart';
import 'package:spotshare/features/profile/presentation/widgets/avatar_picker.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_profile_repository.dart';
import '../../../../helpers/pump_app.dart';

class _MockImagePicker extends Mock implements ImagePicker {}

void main() {
  late _MockImagePicker picker;
  late FakeProfileRepository profile;

  setUp(() {
    picker = _MockImagePicker();
    profile = FakeProfileRepository(null);
  });

  Future<ProviderContainer> pumpSetupPage(WidgetTester tester) async {
    final container = await pumpApp(
      tester,
      auth: FakeAuthRepository(FakeAuthRepository.user),
      profile: profile,
      overrides: [imagePickerProvider.overrideWithValue(picker)],
    );
    await tester.pumpAndSettle();
    return container;
  }

  void whenPicked(ImageSource source, XFile? file) => when(
    () => picker.pickImage(
      source: source,
      maxWidth: any(named: 'maxWidth'),
      maxHeight: any(named: 'maxHeight'),
      imageQuality: any(named: 'imageQuality'),
    ),
  ).thenAnswer((_) async => file);

  testWidgets('propose l’appareil photo et la galerie', (tester) async {
    await pumpSetupPage(tester);

    await tester.tap(find.byType(AvatarPicker));
    await tester.pumpAndSettle();

    expect(find.text('Prendre une photo'), findsOneWidget);
    expect(find.text('Choisir dans la galerie'), findsOneWidget);
  });

  testWidgets('affiche la photo prise et l’envoie avec le profil', (
    tester,
  ) async {
    whenPicked(ImageSource.camera, XFile('/tmp/avatar.jpg'));
    await pumpSetupPage(tester);

    await tester.tap(find.byType(AvatarPicker));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prendre une photo'));
    await tester.pumpAndSettle();

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect((avatar.foregroundImage! as FileImage).file.path, '/tmp/avatar.jpg');

    await tester.enterText(find.byType(TextFormField).first, 'Camille');
    await tester.tap(find.text('C’est parti'));
    await tester.pumpAndSettle();

    expect(profile.savedAvatarPath, '/tmp/avatar.jpg');
  });

  testWidgets('garde l’avatar vide quand l’utilisateur annule', (tester) async {
    whenPicked(ImageSource.gallery, null);
    final container = await pumpSetupPage(tester);

    await tester.tap(find.byType(AvatarPicker));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choisir dans la galerie'));
    await tester.pumpAndSettle();

    expect(container.read(pickedAvatarProvider), isNull);
    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.foregroundImage, isNull);
  });
}
