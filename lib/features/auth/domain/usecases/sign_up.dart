import 'package:spotshare/features/auth/domain/repositories/auth_repository.dart';

class SignUp {
  const SignUp(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email, required String password}) =>
      _repository.signUp(email: email, password: password);
}
