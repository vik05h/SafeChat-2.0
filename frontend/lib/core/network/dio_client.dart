import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:io';
import '../../app/config/environment.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.env.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
      return handler.next(options);
    },
    onError: (DioException error, handler) async {
      // Log to Crashlytics
      FirebaseCrashlytics.instance.recordError(
        error,
        error.stackTrace,
        reason: 'Dio Error: ${error.requestOptions.path}',
        information: [error.response?.data?.toString() ?? 'No Response Body'],
      );

      // Retry Logic for network failures or 5xx errors
      final isNetworkError = error.type == DioExceptionType.connectionTimeout || 
                             error.type == DioExceptionType.receiveTimeout || 
                             error.type == DioExceptionType.unknown && error.error is SocketException;
                             
      final isServerError = error.response != null && error.response!.statusCode! >= 500;

      if (isNetworkError || isServerError) {
        final extra = error.requestOptions.extra;
        int retryCount = extra['retry_count'] ?? 0;
        
        if (retryCount < 3) {
          retryCount++;
          error.requestOptions.extra['retry_count'] = retryCount;
          
          // Exponential backoff
          await Future.delayed(Duration(seconds: retryCount * 2));
          
          try {
            final response = await dio.fetch(error.requestOptions);
            return handler.resolve(response);
          } catch (e) {
            return handler.next(error);
          }
        }
      }
      
      return handler.next(error);
    },
  ));

  return dio;
});
