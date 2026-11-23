import 'package:cloud_firestore/cloud_firestore.dart';

class SpotCommentDto {
  const SpotCommentDto({
    required this.id,
    required this.authorId,
    required this.text,
    required this.createdAt,
  });

  factory SpotCommentDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return SpotCommentDto(
      id: snapshot.id,
      authorId: data['authorId'] as String,
      text: data['text'] as String,
      // Date serveur absente : écriture locale pas encore confirmée.
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  final String id;
  final String authorId;
  final String text;
  final DateTime createdAt;
}
