import 'package:todo_mobile/models/todo.dart';
import 'package:todo_mobile/utils/result.dart';

class CreateTodoData {
  final String title;
  final String description;
  final bool isCompleted;

  CreateTodoData({
    required this.title,
    required this.description,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }
}

abstract class TodoRepository {
  Future<Result<Todo, String>> getTodoById(String id);
  Future<Result<List<Todo>, String>> listTodos({
    String? term,
    bool? isCompleted,
  });
  Future<Result<void, String>> addTodo(CreateTodoData todo);
  Future<Result<void, String>> completeTodo(String id);
}
