import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  final baseUrl = dotenv.isInitialized 
      ? (dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000')
      : 'http://10.0.2.2:8000';
  dio.options.baseUrl = baseUrl;
  dio.options.connectTimeout = const Duration(seconds: 10);
  dio.options.receiveTimeout = const Duration(seconds: 10);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Attempt to attach Firebase ID Token to every request
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          try {
            final token = await user.getIdToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e) {
            // Token refresh might fail if offline or logged out
          }
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Handle global error responses here if needed (e.g., refreshing token)
        return handler.next(error);
      },
    ),
  );

  return dio;
});
