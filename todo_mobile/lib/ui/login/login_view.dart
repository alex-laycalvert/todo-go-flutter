import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:todo_mobile/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SignInScreen(
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                context.go(Routes.home);
              }),
              AuthStateChangeAction<UserCreated>((context, state) {
                context.go(Routes.home);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
