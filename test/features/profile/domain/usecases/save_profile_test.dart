import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/features/profile/domain/entities/user_profile.dart';
import 'package:spotshare/features/profile/domain/usecases/save_profile.dart';

import '../../../../helpers/fake_profile_repository.dart';

void main() {
  test('retire les espaces autour du nom et de la bio', () async {
    final repository = FakeProfileRepository(null);
    addTearDown(repository.dispose);

    await SaveProfile(repository)(
      const UserProfile(id: 'uid', displayName: '  Camille ', bio: ' Cafés '),
      avatarPath: '/tmp/a.jpg',
    );

    expect(
      repository.saved,
      const UserProfile(id: 'uid', displayName: 'Camille', bio: 'Cafés'),
    );
    expect(repository.savedAvatarPath, '/tmp/a.jpg');
  });
}
