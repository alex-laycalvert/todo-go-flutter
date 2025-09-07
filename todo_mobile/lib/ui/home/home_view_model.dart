import 'package:flutter/widgets.dart';
import 'package:todo_mobile/models/user.dart';
import 'package:todo_mobile/use_cases/authenticated_user/authenticated_user_use_case.dart';

class HomeViewModel extends ChangeNotifier {
  final AuthenticatedUserUseCase authenticatedUserUseCase;

  HomeViewModel({required this.authenticatedUserUseCase});

  User get user => authenticatedUserUseCase.user!;
}
