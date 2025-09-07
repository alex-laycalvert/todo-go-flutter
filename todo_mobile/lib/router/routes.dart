abstract class RouteParams {
  static const String todoId = 'todoId';
}

abstract class Routes {
  static const String login = '/login';

  static const String home = '/home';

  static const String configure = '/configure';

  static const String todos = '/todos';
  static const String todo = '/todos/:${RouteParams.todoId}';
  static String todoWithId(String todoId) => '/todos/$todoId';
}
