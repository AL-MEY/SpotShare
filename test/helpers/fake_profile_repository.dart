import 'dart:async';

import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/features/profile/domain/entities/user_profile.dart';
import 'package:spotshare/features/profile/domain/repositories/profile_repository.dart';

import 'fake_auth_repository.dart';

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository([this._profile = profile]);

  static const profile = UserProfile(
    id: 'uid',
    displayName: 'Camille',
    bio: 'Amatrice de cafés',
  );

  UserProfile? _profile;
  Failure? failure;
  String? savedAvatarPath;
  final _controller = StreamController<UserProfile?>.broadcast();

  UserProfile? get saved => _profile;

  Future<void> dispose() => _controller.close();

  @override
  Stream<UserProfile?> watchProfile(String userId) async* {
    assert(userId == FakeAuthRepository.user.id);
    final failure = this.failure;
    if (failure != null) throw failure;
    yield _profile;
    yield* _controller.stream;
  }

  @override
  Future<void> saveProfile(UserProfile profile, {String? avatarPath}) async {
    final failure = this.failure;
    if (failure != null) throw failure;
    savedAvatarPath = avatarPath;
    _profile = profile;
    _controller.add(profile);
  }
}
