// ignore_for_file: subtype_of_sealed_class

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotshare/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:spotshare/features/profile/data/models/user_profile_dto.dart';

class _MockFirestore extends Mock implements FirebaseFirestore {}

class _MockStorage extends Mock implements FirebaseStorage {}

class _MockCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _MockDocument extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class _MockSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class _MockMetadata extends Mock implements SnapshotMetadata {}

class _MockReference extends Mock implements Reference {}

class _FakeTaskSnapshot extends Fake implements TaskSnapshot {}

class _CompletedUploadTask extends Fake implements UploadTask {
  final _done = Future<TaskSnapshot>.value(_FakeTaskSnapshot());

  @override
  Future<R> then<R>(
    FutureOr<R> Function(TaskSnapshot) onValue, {
    Function? onError,
  }) => _done.then(onValue, onError: onError);
}

_MockSnapshot _snapshot({required bool exists, required bool fromCache}) {
  final metadata = _MockMetadata();
  when(() => metadata.isFromCache).thenReturn(fromCache);
  final snapshot = _MockSnapshot();
  when(() => snapshot.exists).thenReturn(exists);
  when(() => snapshot.metadata).thenReturn(metadata);
  when(() => snapshot.id).thenReturn('uid');
  when(snapshot.data)
      .thenReturn(exists ? {'displayName': 'Camille', 'bio': 'Cafés'} : null);
  return snapshot;
}

void main() {
  late _MockFirestore firestore;
  late _MockStorage storage;
  late _MockDocument document;
  late ProfileRemoteDataSource dataSource;

  setUpAll(() {
    registerFallbackValue(File(''));
    registerFallbackValue(SettableMetadata());
  });

  setUp(() {
    firestore = _MockFirestore();
    storage = _MockStorage();
    final collection = _MockCollection();
    document = _MockDocument();
    when(() => firestore.collection('users')).thenReturn(collection);
    when(() => collection.doc('uid')).thenReturn(document);
    dataSource = ProfileRemoteDataSource(firestore, storage);
  });

  void whenSnapshots(List<_MockSnapshot> snapshots) =>
      when(() => document.snapshots())
          .thenAnswer((_) => Stream.fromIterable(snapshots));

  test('ignore un document absent du cache local et attend le serveur', () {
    whenSnapshots([
      _snapshot(exists: false, fromCache: true),
      _snapshot(exists: true, fromCache: false),
    ]);

    expect(
      dataSource.watchProfile('uid'),
      emits(isA<UserProfileDto>().having((p) => p.id, 'id', 'uid')),
    );
  });

  test('émet null quand le serveur confirme que le profil n’existe pas', () {
    whenSnapshots([_snapshot(exists: false, fromCache: false)]);

    expect(dataSource.watchProfile('uid'), emits(isNull));
  });

  test('émet le profil en cache sans attendre le serveur', () {
    whenSnapshots([_snapshot(exists: true, fromCache: true)]);

    expect(
      dataSource.watchProfile('uid'),
      emits(
        isA<UserProfileDto>().having((p) => p.displayName, 'nom', 'Camille'),
      ),
    );
  });

  test('fusionne le profil dans users/{uid}', () async {
    when(() => document.set(any(), any())).thenAnswer((_) async {});

    await dataSource.saveProfile(
      const UserProfileDto(id: 'uid', displayName: 'Camille', bio: ''),
    );

    final options =
        verify(() => document.set(any(), captureAny())).captured.single
            as SetOptions;
    expect(options.merge, isTrue);
  });

  test('téléverse l’avatar sous un nom unique et renvoie son URL', () async {
    final reference = _MockReference();
    when(() => storage.ref(any())).thenReturn(reference);
    when(() => reference.putFile(any(), any()))
        .thenAnswer((_) => _CompletedUploadTask());
    when(reference.getDownloadURL).thenAnswer((_) async => 'https://a');

    final url = await dataSource.uploadAvatar('uid', '/tmp/photo.JPG');

    final path = verify(() => storage.ref(captureAny())).captured.single;
    expect(path, matches(RegExp(r'^users/uid/avatar_[0-9]+\.jpg$')));
    expect(url, 'https://a');
    final metadata =
        verify(() => reference.putFile(any(), captureAny())).captured.single
            as SettableMetadata;
    expect(metadata.contentType, 'image/jpeg');
  });
}
