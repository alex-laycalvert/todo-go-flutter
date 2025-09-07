import 'dart:async';
import 'package:todo_mobile/models/user.dart';
import 'package:todo_mobile/repositories/auth/auth_repository.dart';
import 'package:todo_mobile/repositories/user/user_repository.dart';
import 'package:todo_mobile/utils/result.dart';

class AuthenticatedUserUseCase {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  AuthenticatedUserUseCase({
    required this.authRepository,
    required this.userRepository,
  }) {
    authRepository.subscribe((isAuthenticated) {
      if (!isAuthenticated) {
        _user = null;
        return;
      }
    });
  }

  User? _user;

  User? get user => _user;
  bool get isAuthenticated => authRepository.isAuthenticated();

  Future<Result<User, String>> getUser() async {
    final result = await userRepository.getUser("me");

    switch (result) {
      case Ok(value: final user):
        _user = user;
        return Ok(user);
      case Err(error: final error):
        _user = null;
        return Err(error);
    }
  }
}
