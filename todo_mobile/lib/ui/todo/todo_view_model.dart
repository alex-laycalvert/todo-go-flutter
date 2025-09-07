import 'package:flutter/widgets.dart';
import 'package:todo_mobile/models/todo.dart';
import 'package:todo_mobile/repositories/todo/todo_repository.dart';
import 'package:todo_mobile/utils/result.dart';

class TodoViewModel extends ChangeNotifier {
  final String todoId;
  final String? todoTitle;
  final TodoRepository todoRepository;

  TodoViewModel({
    required this.todoId,
    this.todoTitle,
    required this.todoRepository,
  });

  Todo? _todo;
  bool _fetching = false;
  bool _completing = false;
  String? _error;

  Todo? get todo => _todo;
  bool get fetching => _fetching;
  bool get completing => _completing;
  bool get loading => _fetching | _completing;
  String? get error => _error;

  Future<void> fetchTodo() async {
    if (loading) {
      return;
    }

    _fetching = true;
    _error = null;
    notifyListeners();

    final result = await todoRepository.getTodoById(todoId);
    switch (result) {
      case Ok(value: final todo):
        _todo = todo;
        break;
      case Err(error: final error):
        _error = error;
        break;
    }

    _fetching = false;
    notifyListeners();
  }

  Future<void> completeTodo() async {
    if (loading || _todo == null || _todo!.isCompleted) {
      return;
    }

    _completing = true;
    _error = null;
    notifyListeners();

    final result = await todoRepository.completeTodo(todoId);
    _completing = false;
    if (result case Err(error: final error)) {
      _error = error;
      notifyListeners();
      return;
    }

    notifyListeners();
    fetchTodo();
  }
}
