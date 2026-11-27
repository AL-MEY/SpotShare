import 'package:cloud_firestore/cloud_firestore.dart';

class SpotAuthorDto {
  const SpotAuthorDto({
    required this.id,
    required this.displayName,
    this.avatarUrl,
  });

  factory SpotAuthorDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return SpotAuthorDto(
      id: snapshot.id,
      displayName: data['displayName'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String?,
    );
  }

  final String id;
  final String displayName;
  final String? avatarUrl;
}
