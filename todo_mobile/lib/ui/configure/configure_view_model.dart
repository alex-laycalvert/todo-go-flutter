import 'package:flutter/widgets.dart';
import 'package:todo_mobile/repositories/user/user_repository.dart';
import 'package:todo_mobile/utils/result.dart';

class ConfigureViewModel extends ChangeNotifier {
  final UserRepository userRepository;

  ConfigureViewModel({required this.userRepository});

  final formKey = GlobalKey<FormState>();
  final formControllers = {'name': TextEditingController()};
  final formValidators = {
    'name': (String? value) {
      if (value == null || value.isEmpty) {
        return 'Name is required';
      }
      return null;
    },
  };

  bool _configuring = false;
  String? _error;

  bool get configuring => _configuring;
  String? get error => _error;

  Future<void> configure(VoidCallback onConfigure) async {
    if (_configuring || !formKey.currentState!.validate()) {
      return;
    }

    _configuring = true;
    _error = null;
    notifyListeners();

    final name = formControllers['name']!.text;
    final result = await userRepository.updateUser(
      "me",
      UpdateUserData(name: name),
    );
    switch (result) {
      case Ok():
        onConfigure();
        break;
      case Err(error: final error):
        _error = error;
        break;
    }

    _configuring = false;
    notifyListeners();
  }
}
