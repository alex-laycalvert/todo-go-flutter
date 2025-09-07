import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:todo_mobile/models/user.dart';
import 'package:todo_mobile/repositories/user/user_repository.dart';
import 'package:todo_mobile/utils/result.dart';

class UserRepositoryRemote implements UserRepository {
  final Dio client;

  UserRepositoryRemote({required this.client});

  @override
  Future<Result<User, String>> getUser(String userId) async {
    try {
      final response = await client.get('/users/$userId');
      if (response.statusCode == 200) {
        final user = User.fromJson(json.decode(response.data));
        return Result.ok(value: user);
      }

      return Result.err(error: response.statusMessage ?? 'Unknown error');
    } catch (e) {
      if (e is DioException) {
        return Result.err(
          error:
              e.response?.data.toString().trim() ??
              e.message?.trim() ??
              'Unknown Error',
        );
      }

      return Result.err(error: e.toString());
    }
  }

  @override
  Future<Result<void, String>> updateUser(
    String userId,
    UpdateUserData data,
  ) async {
    try {
      final response = await client.put('/users/$userId', data: data.toJson());
      if (response.statusCode == 200) {
        return Result.ok(value: null);
      }

      return Result.err(error: response.statusMessage ?? 'Unknown error');
    } catch (e) {
      if (e is DioException) {
        return Result.err(
          error:
              e.response?.data.toString().trim() ??
              e.message?.trim() ??
              'Unknown Error',
        );
      }

      return Result.err(error: e.toString());
    }
  }
}
