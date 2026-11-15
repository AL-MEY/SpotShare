import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileDto {
  const UserProfileDto({
    required this.id,
    required this.displayName,
    required this.bio,
    this.avatarUrl,
  });

  factory UserProfileDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return UserProfileDto(
      id: snapshot.id,
      displayName: data['displayName'] as String,
      bio: data['bio'] as String,
      avatarUrl: data['avatarUrl'] as String?,
    );
  }

  final String id;
  final String displayName;
  final String bio;
  final String? avatarUrl;

  Map<String, dynamic> toFirestore() => {
    'displayName': displayName,
    'bio': bio,
    'avatarUrl': avatarUrl,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
