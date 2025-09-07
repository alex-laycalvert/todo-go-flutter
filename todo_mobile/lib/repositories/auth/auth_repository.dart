import 'package:todo_mobile/utils/result.dart';

abstract class AuthRepository {
  /// Whether or not the user is currently authenticated
  bool isAuthenticated();

  /// Allows the caller to subscribe to changes in authentication
  void subscribe(void Function(bool isAuthenticated) listener);

  Future<Result<void, String>> logout();
}
