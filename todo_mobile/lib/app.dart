import 'package:flutter/material.dart';
import 'package:todo_mobile/router/router.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(),
      routerConfig: router,
    );
  }
}
