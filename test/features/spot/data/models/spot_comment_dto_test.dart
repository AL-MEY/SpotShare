import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/features/spot/data/models/spot_comment_dto.dart';

Future<DocumentSnapshot<Map<String, dynamic>>> _snapshot(
  Map<String, dynamic> data,
) async {
  final firestore = FakeFirebaseFirestore();
  await firestore.doc('spots/s1/comments/c1').set(data);
  return firestore.doc('spots/s1/comments/c1').get();
}

void main() {
  test('lit un commentaire complet', () async {
    final dto = SpotCommentDto.fromFirestore(
      await _snapshot({
        'authorId': 'u1',
        'text': 'Super spot',
        'createdAt': Timestamp.fromDate(DateTime(2026, 11)),
      }),
    );

    expect(dto.id, 'c1');
    expect(dto.authorId, 'u1');
    expect(dto.text, 'Super spot');
    expect(dto.createdAt, DateTime(2026, 11));
  });

  test('un commentaire sans date serveur prend la date courante', () async {
    final before = DateTime.now();

    final dto = SpotCommentDto.fromFirestore(
      await _snapshot({'authorId': 'u1', 'text': 'Super spot'}),
    );

    expect(dto.createdAt.isBefore(before), isFalse);
    expect(dto.createdAt.isAfter(DateTime.now()), isFalse);
  });
}
