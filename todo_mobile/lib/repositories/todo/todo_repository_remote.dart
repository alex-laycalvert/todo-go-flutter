import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:todo_mobile/models/todo.dart';
import 'package:todo_mobile/repositories/todo/todo_repository.dart';
import 'package:todo_mobile/utils/result.dart';

class TodoRepositoryRemote implements TodoRepository {
  final Dio _client;

  TodoRepositoryRemote({required Dio client}) : _client = client;

  @override
  Future<Result<Todo, String>> getTodoById(String id) async {
    try {
      final response = await _client.get('/todos/$id');
      if (response.statusCode == 200) {
        final result = json.decode(response.data) as Map<String, dynamic>;
        final todo = Todo.fromJson(result);
        return Result.ok(value: todo);
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
  Future<Result<List<Todo>, String>> listTodos({
    String? term,
    bool? isCompleted,
  }) async {
    try {
      final response = await _client.get(
        '/todos',
        queryParameters: {
          if (term != null && term.isNotEmpty) 'term': term,
          if (isCompleted != null) 'is_completed': isCompleted,
        },
      );
      if (response.statusCode == 200) {
        final result = json.decode(response.data) as Map<String, dynamic>;
        final todos = (result['todos']! as List<dynamic>).map((todoJson) {
          return Todo.fromJson(todoJson);
        }).toList();
        return Result.ok(value: todos);
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
  Future<Result<void, String>> addTodo(CreateTodoData todo) async {
    try {
      final response = await _client.post(
        '/todos',
        data: json.encode(todo.toJson()),
      );
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

  @override
  Future<Result<void, String>> completeTodo(String id) async {
    try {
      final response = await _client.post('/todos/$id');
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
