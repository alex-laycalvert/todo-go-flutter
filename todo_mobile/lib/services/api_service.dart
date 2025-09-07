import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

Dio createDioClient({required FirebaseAuth firebaseAuth}) {
  final dioClient = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dioClient.interceptors.add(
    _FirebaseAuthInterceptor(firebaseAuth: firebaseAuth),
  );

  return dioClient;
}

class _FirebaseAuthInterceptor extends Interceptor {
  final FirebaseAuth _firebaseAuth;

  _FirebaseAuthInterceptor({required FirebaseAuth firebaseAuth})
    : _firebaseAuth = firebaseAuth;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final idToken = await user.getIdToken();
      options.headers['Authorization'] = 'Bearer $idToken';
    }
    return handler.next(options);
  }
}
