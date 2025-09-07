import 'package:flutter/widgets.dart';
import 'package:todo_mobile/use_cases/authenticated_user/authenticated_user_use_case.dart';
import 'package:todo_mobile/utils/result.dart';

class AppViewModel extends ChangeNotifier {
  final AuthenticatedUserUseCase authenticatedUserUserCase;

  bool _loading;
  String? _error;

  AppViewModel({required this.authenticatedUserUserCase})
    : _loading =
          authenticatedUserUserCase.isAuthenticated &&
          authenticatedUserUserCase.user == null {
    refetch();
  }

  bool get loading => _loading;
  String? get error => _error;

  Future<void> refetch() async {
    if (!authenticatedUserUserCase.isAuthenticated) {
      _error = 'User not authenticated';
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    // Force re-fetch user
    final user = await authenticatedUserUserCase.getUser();
    switch (user) {
      case Ok(value: _):
        _error = null;
      case Err(error: final error):
        _error = error;
    }
    _loading = false;
    notifyListeners();
  }
}
