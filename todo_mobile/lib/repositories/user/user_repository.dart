import 'package:todo_mobile/models/user.dart';
import 'package:todo_mobile/utils/result.dart';

class UpdateUserData {
  final String name;

  UpdateUserData({required this.name});

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}

abstract class UserRepository {
  Future<Result<User, String>> getUser(String userId);
  Future<Result<void, String>> updateUser(String userId, UpdateUserData data);
}
