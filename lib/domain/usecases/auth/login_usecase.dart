import 'package:medicare_app/data/repositories/auth_repository.dart';

import '../../entities/user_entity.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> execute({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    if ((email == null || email.isEmpty) &&
        (phoneNumber == null || phoneNumber.isEmpty)) {
      throw Exception('Either email or phone number is required');
    }

    if (password.isEmpty) {
      throw Exception('Password is required');
    }

    return await repository.login(
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
  }
}
