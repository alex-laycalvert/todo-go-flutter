import 'package:todo_mobile/repositories/todo/todo_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:todo_mobile/utils/result.dart';

class AddTodoViewModel extends ChangeNotifier {
  final TodoRepository todoRepository;

  AddTodoViewModel({required this.todoRepository});

  final formKey = GlobalKey<FormState>();
  final formControllers = {
    'title': TextEditingController(),
    'description': TextEditingController(),
  };
  final formValidators = {
    'title': (String? value) {
      if (value == null || value.isEmpty) {
        return 'Title is required';
      }
      return null;
    },
    'description': (String? value) {
      return null;
    },
  };

  bool _adding = false;
  String? _error;

  bool get adding => _adding;
  String? get error => _error;

  Future<void> addTodo(VoidCallback onAdd) async {
    if (_adding || !formKey.currentState!.validate()) {
      return;
    }

    _adding = true;
    _error = null;
    notifyListeners();

    final title = formControllers['title']!.text;
    final description = formControllers['description']!.text;
    final result = await todoRepository.addTodo(
      CreateTodoData(title: title, description: description),
    );
    switch (result) {
      case Ok():
        onAdd();
        break;
      case Err(error: final error):
        _error = error;
        break;
    }

    _adding = false;
    notifyListeners();
  }
}
