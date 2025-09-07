import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_mobile/models/todo.dart';
import 'package:todo_mobile/repositories/auth/auth_repository.dart';
import 'package:todo_mobile/router/routes.dart';
import 'package:provider/provider.dart';
import 'package:todo_mobile/ui/app/app_view.dart';
import 'package:todo_mobile/ui/app/app_view_model.dart';
import 'package:todo_mobile/ui/configure/configure_view.dart';
import 'package:todo_mobile/ui/configure/configure_view_model.dart';
import 'package:todo_mobile/ui/home/home_view.dart';
import 'package:todo_mobile/ui/home/home_view_model.dart';
import 'package:todo_mobile/ui/login/login_view.dart';
import 'package:todo_mobile/ui/logout/logout_view.dart';
import 'package:todo_mobile/ui/logout/logout_view_model.dart';
import 'package:todo_mobile/ui/todo/todo_view.dart';
import 'package:todo_mobile/ui/todo/todo_view_model.dart';
import 'package:todo_mobile/ui/todos/todos_view.dart';
import 'package:todo_mobile/ui/todos/todos_view_model.dart';
import 'package:todo_mobile/use_cases/authenticated_user/authenticated_user_use_case.dart';
import 'package:todo_mobile/utils/result.dart';

class Tab {
  final String label;
  final IconData icon;
  final String? path;
  final void Function(BuildContext context)? onPressed;

  Tab({required this.label, required this.icon, this.path, this.onPressed});

  void goto(BuildContext context) {
    if (path != null) {
      context.go(path!);
    } else if (onPressed != null) {
      onPressed!(context);
    }
  }
}

final _tabs = [
  Tab(label: 'Home', icon: Icons.home, path: Routes.home),
  Tab(label: 'Todos', icon: Icons.list, path: Routes.todos),
  Tab(
    label: 'Logout',
    icon: Icons.exit_to_app,
    onPressed: (context) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return ChangeNotifierProvider(
            create: (context) =>
                LogoutViewModel(authRepository: context.read()),
            child: const LogoutView(),
          );
        },
      );
    },
  ),
];

final router = GoRouter(
  initialLocation: Routes.home,
  redirect: (context, state) async {
    final authUseCase = context.read<AuthenticatedUserUseCase>();

    if (!authUseCase.isAuthenticated) {
      return Routes.login;
    }

    final userResult = await authUseCase.getUser();
    if (userResult case Err()) {
      await authUseCase.authRepository.logout();
      return Routes.login;
    }
    final user = userResult.unwrap();

    if (!user.isConfigured) {
      return Routes.configure;
    }

    if (state.matchedLocation == Routes.login) {
      return Routes.home;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: Routes.login,
      builder: (context, state) {
        return LoginView();
      },
    ),
    GoRoute(
      path: Routes.configure,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text("Configure Profile"),
          ),
          body: ChangeNotifierProvider(
            create: (context) =>
                ConfigureViewModel(userRepository: context.read()),
            child: ConfigureView(),
          ),
        );
      },
    ),
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text("TODOs"),
          ),
          body: ChangeNotifierProvider(
            create: (context) =>
                AppViewModel(authenticatedUserUserCase: context.read()),
            child: AppView(child: child),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: getCurrentIndex(state.fullPath!),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.list), label: 'TODOs'),
              BottomNavigationBarItem(
                icon: Icon(Icons.exit_to_app),
                label: 'Logout',
              ),
            ],
            onTap: (index) {
              if (index >= _tabs.length) {
                return;
              }

              final tab = _tabs[index];
              tab.goto(context);
            },
          ),
        );
      },
      routes: [
        GoRoute(
          path: Routes.home,
          builder: (context, state) {
            return ChangeNotifierProvider(
              create: (context) =>
                  HomeViewModel(authenticatedUserUseCase: context.read()),
              child: HomeView(),
            );
          },
        ),
        GoRoute(
          path: Routes.todos,
          builder: (context, state) {
            return ChangeNotifierProvider(
              create: (context) =>
                  TodosViewModel(todoRepository: context.read()),
              child: TodosView(),
            );
          },
        ),
        GoRoute(
          path: Routes.todo,
          builder: (context, state) {
            final todoId = state.pathParameters[RouteParams.todoId]!;
            final initialTodo = state.extra as Todo?;

            return ChangeNotifierProvider(
              create: (context) => TodoViewModel(
                todoId: todoId,
                todoTitle: initialTodo?.title,
                todoRepository: context.read(),
              ),
              child: TodoView(),
            );
          },
        ),
      ],
    ),
  ],
);

int getCurrentIndex(String location) {
  return _tabs.indexWhere(
    (tab) => tab.path != null && location.startsWith(tab.path!),
  );
}
