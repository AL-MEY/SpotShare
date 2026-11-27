import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/features/spot/data/models/spot_author_dto.dart';

void main() {
  test('lit le nom et l’avatar de l’auteur', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.doc('users/u1').set({
      'displayName': 'Alice',
      'avatarUrl': 'https://example.com/a.jpg',
    });

    final dto = SpotAuthorDto.fromFirestore(
      await firestore.doc('users/u1').get(),
    );

    expect(dto.id, 'u1');
    expect(dto.displayName, 'Alice');
    expect(dto.avatarUrl, 'https://example.com/a.jpg');
  });

  test('l’avatar est optionnel', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.doc('users/u1').set({'displayName': 'Alice'});

    final dto = SpotAuthorDto.fromFirestore(
      await firestore.doc('users/u1').get(),
    );

    expect(dto.avatarUrl, isNull);
  });
}
