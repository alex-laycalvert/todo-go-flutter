import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_mobile/app.dart';
import 'package:todo_mobile/firebase_options.dart';
import 'package:todo_mobile/repositories/auth/auth_repository.dart';
import 'package:todo_mobile/repositories/auth/auth_repository_remote.dart';
import 'package:todo_mobile/repositories/todo/todo_repository.dart';
import 'package:todo_mobile/repositories/todo/todo_repository_remote.dart';
import 'package:todo_mobile/repositories/user/user_repository.dart';
import 'package:todo_mobile/repositories/user/user_repository_remote.dart';
import 'package:todo_mobile/services/api_service.dart';
import 'package:todo_mobile/use_cases/authenticated_user/authenticated_user_use_case.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseUIAuth.configureProviders([EmailAuthProvider()]);

  // Both of the following lines are good for testing,
  // but can be removed for release builds
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  await FirebaseAuth.instance.signOut();

  final dioClient = createDioClient(firebaseAuth: FirebaseAuth.instance);

  runApp(
    MultiProvider(
      providers: [
        // Repositories
        Provider(
          create: (_) =>
              AuthRepositoryRemote(firebaseInstance: FirebaseAuth.instance)
                  as AuthRepository,
        ),
        Provider(
          create: (_) =>
              TodoRepositoryRemote(client: dioClient) as TodoRepository,
        ),
        Provider(
          create: (_) =>
              UserRepositoryRemote(client: dioClient) as UserRepository,
        ),

        // Use Cases
        Provider(
          lazy: true,
          create: (context) => AuthenticatedUserUseCase(
            authRepository: context.read(),
            userRepository: context.read(),
          ),
        ),
      ],
      child: const TodoApp(),
    ),
  );
}
