import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:todo_mobile/repositories/auth/auth_repository.dart';
import 'package:todo_mobile/utils/result.dart';

class AuthRepositoryRemote implements AuthRepository {
  final FirebaseAuth firebaseInstance;

  AuthRepositoryRemote({required this.firebaseInstance});

  @override
  bool isAuthenticated() {
    return firebaseInstance.currentUser != null;
  }

  @override
  void subscribe(void Function(bool isAuthenticated) listener) {
    firebaseInstance.authStateChanges().listen((firebaseUser) {
      listener(firebaseUser != null);
    });
  }

  @override
  Future<Result<void, String>> logout() async {
    try {
      await firebaseInstance.signOut();
      return const Ok(null);
    } catch (e) {
      return Err(e.toString());
    }
  }
}
