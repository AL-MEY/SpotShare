import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:spotshare/features/profile/data/models/user_profile_dto.dart';
import 'package:spotshare/features/profile/data/repositories/firebase_profile_repository.dart';
import 'package:spotshare/features/profile/domain/entities/user_profile.dart';

class _MockRemote extends Mock implements ProfileRemoteDataSource {}

const _dto = UserProfileDto(
  id: 'uid',
  displayName: 'Camille',
  bio: 'Cafés',
  avatarUrl: 'https://old',
);
const _profile = UserProfile(
  id: 'uid',
  displayName: 'Camille',
  bio: 'Cafés',
  avatarUrl: 'https://old',
);

void main() {
  late _MockRemote remote;
  late FirebaseProfileRepository repository;

  setUpAll(() => registerFallbackValue(_dto));

  setUp(() {
    remote = _MockRemote();
    repository = FirebaseProfileRepository(remote);
    when(() => remote.saveProfile(any())).thenAnswer((_) async {});
    when(() => remote.deleteFile(any())).thenAnswer((_) async {});
  });

  test('convertit le document en UserProfile, null si absent', () {
    when(() => remote.watchProfile('uid'))
        .thenAnswer((_) => Stream.fromIterable([null, _dto]));

    expect(repository.watchProfile('uid'), emitsInOrder([null, _profile]));
  });

  test('convertit une erreur Firestore du flux en Failure', () {
    when(() => remote.watchProfile('uid')).thenAnswer(
      (_) => Stream.error(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      ),
    );

    expect(
      repository.watchProfile('uid'),
      emitsError(isA<PermissionFailure>()),
    );
  });

  test('enregistre sans téléverser quand l’avatar ne change pas', () async {
    await repository.saveProfile(_profile);

    final saved =
        verify(() => remote.saveProfile(captureAny())).captured.single
            as UserProfileDto;
    expect(saved.avatarUrl, 'https://old');
    verifyNever(() => remote.uploadAvatar(any(), any()));
    verifyNever(() => remote.deleteFile(any()));
  });

  test('téléverse le nouvel avatar, enregistre son URL puis supprime '
      'l’ancien', () async {
    when(() => remote.uploadAvatar('uid', '/tmp/a.jpg'))
        .thenAnswer((_) async => 'https://new');

    await repository.saveProfile(_profile, avatarPath: '/tmp/a.jpg');

    final saved =
        verify(() => remote.saveProfile(captureAny())).captured.single
            as UserProfileDto;
    expect(saved.avatarUrl, 'https://new');
    verify(() => remote.deleteFile('https://old')).called(1);
  });

  test('n’enregistre rien si le téléversement échoue', () {
    when(() => remote.uploadAvatar(any(), any())).thenThrow(
      FirebaseException(plugin: 'firebase_storage', code: 'unauthorized'),
    );

    expect(
      repository.saveProfile(_profile, avatarPath: '/tmp/a.jpg'),
      throwsA(isA<PermissionFailure>()),
    );
    verifyNever(() => remote.saveProfile(any()));
  });

  test('ignore l’échec de suppression de l’ancien avatar', () async {
    when(() => remote.uploadAvatar(any(), any()))
        .thenAnswer((_) async => 'https://new');
    when(() => remote.deleteFile(any())).thenThrow(Exception('boom'));

    await expectLater(
      repository.saveProfile(_profile, avatarPath: '/tmp/a.jpg'),
      completes,
    );
  });
}
