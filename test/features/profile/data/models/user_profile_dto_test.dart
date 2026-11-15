// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotshare/features/profile/data/models/user_profile_dto.dart';

class _MockSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  test('lit le document Firestore', () {
    final snapshot = _MockSnapshot();
    when(() => snapshot.id).thenReturn('uid');
    when(snapshot.data).thenReturn({
      'displayName': 'Camille',
      'bio': 'Cafés',
      'avatarUrl': 'https://a',
      'updatedAt': Timestamp.now(),
    });

    final dto = UserProfileDto.fromFirestore(snapshot);

    expect(dto.id, 'uid');
    expect(dto.displayName, 'Camille');
    expect(dto.bio, 'Cafés');
    expect(dto.avatarUrl, 'https://a');
  });

  test('écrit exactement les champs autorisés par les règles', () {
    const dto = UserProfileDto(id: 'uid', displayName: 'Camille', bio: '');

    final data = dto.toFirestore();

    expect(data.keys, {'displayName', 'bio', 'avatarUrl', 'updatedAt'});
    expect(data['updatedAt'], isA<FieldValue>());
  });
}
