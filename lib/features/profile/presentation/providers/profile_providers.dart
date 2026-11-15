import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotshare/core/providers/submit_controller.dart';
import 'package:spotshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:spotshare/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:spotshare/features/profile/data/repositories/firebase_profile_repository.dart';
import 'package:spotshare/features/profile/domain/entities/user_profile.dart';
import 'package:spotshare/features/profile/domain/repositories/profile_repository.dart';
import 'package:spotshare/features/profile/domain/usecases/save_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => FirebaseProfileRepository(
    ProfileRemoteDataSource(
      FirebaseFirestore.instance,
      FirebaseStorage.instance,
    ),
  ),
);

final currentProfileProvider = StreamProvider<UserProfile?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(null);
  return ref.watch(profileRepositoryProvider).watchProfile(userId);
}, retry: (_, _) => null);

final saveProfileProvider = Provider(
  (ref) => SaveProfile(ref.watch(profileRepositoryProvider)),
);

final profileSetupControllerProvider =
    AsyncNotifierProvider.autoDispose<SubmitController, void>(
      SubmitController.new,
    );

final imagePickerProvider = Provider((ref) => ImagePicker());

final pickedAvatarProvider =
    NotifierProvider.autoDispose<PickedAvatar, String?>(PickedAvatar.new);

class PickedAvatar extends Notifier<String?> {
  static const _maxSize = 512.0;

  @override
  String? build() => null;

  Future<void> pick(ImageSource source) async {
    final file = await ref
        .read(imagePickerProvider)
        .pickImage(
          source: source,
          maxWidth: _maxSize,
          maxHeight: _maxSize,
          imageQuality: 85,
        );
    if (file != null && ref.mounted) state = file.path;
  }
}
