import 'package:flutter/widgets.dart';
import 'package:todo_mobile/repositories/auth/auth_repository.dart';

class LogoutViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  LogoutViewModel({required this.authRepository});

  bool _loggingOut = false;
  String? _error;

  bool get loggingOut => _loggingOut;
  String? get error => _error;

  Future<void> logout(VoidCallback onLogout) async {
    _loggingOut = true;
    _error = null;
    notifyListeners();

    try {
      await authRepository.logout();
      onLogout();
    } catch (e) {
      _error = 'Failed to logout';
    } finally {
      _loggingOut = false;
      notifyListeners();
    }
  }
}
