import 'package:todo_mobile/models/todo.dart';
import 'package:todo_mobile/repositories/todo/todo_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:todo_mobile/utils/result.dart';

class TodosViewModel extends ChangeNotifier {
  final TodoRepository todoRepository;

  TodosViewModel({required this.todoRepository});

  TextEditingController searchController = TextEditingController();

  List<Todo> _todos = [];
  bool _fetching = false;
  bool _completing = false;
  String? _error;

  List<Todo> get todos => _todos;
  bool get fetching => _fetching;
  bool get completing => _completing;
  String? get error => _error;

  Future<void> fetchTodos(String? term) async {
    if (_fetching) {
      return;
    }

    _fetching = true;
    _error = null;
    notifyListeners();

    final result = await todoRepository.listTodos(
      term: term,
      isCompleted: false,
    );
    switch (result) {
      case Ok<List<Todo>, String>(value: final data):
        _todos = data;
        break;
      case Err(error: final error):
        _error = error;
        _todos = [];
        break;
    }

    _fetching = false;
    notifyListeners();
  }

  Future<void> completeTodo(String todoId) async {
    if (_completing) {
      return;
    }

    _completing = true;
    _error = null;
    notifyListeners();

    final result = await todoRepository.completeTodo(todoId);
    switch (result) {
      case Ok<void, String>():
        _todos.removeWhere((todo) => todo.id == todoId);
        break;
      case Err(error: final error):
        _error = error;
        break;
    }
    _completing = false;

    notifyListeners();
  }
}
