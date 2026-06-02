import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

// Background handler must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `Firebase.initializeApp()` before using other Firebase services.
  print("Handling a background message: ${message.messageId}");
}

final fcmServiceProvider = Provider<FCMService>((ref) {
  return FCMService(FirebaseMessaging.instance, ref.watch(dioProvider));
});

class FCMService {
  final FirebaseMessaging _messaging;
  final Dio _dio;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  FCMService(this._messaging, this._dio);

  Future<void> initialize(GoRouter router) async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      await _registerToken();
    }

    // Initialize local notifications for foreground display
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          _handleDeepLink(jsonDecode(details.payload!), router);
        }
      },
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Background messages opened by user
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleDeepLink(message.data, router);
    });

    // Terminated state message opened by user
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // Need a small delay to ensure router is ready
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleDeepLink(initialMessage.data, router);
      });
    }

    // Handle token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      _sendTokenToServer(token);
    });
  }

  Future<void> _registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _sendTokenToServer(token);
      }
    } catch (e) {
      print('Failed to get FCM token: $e');
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      await _dio.post('/users/device-token', data: {'token': token});
    } catch (e) {
      print('Failed to send FCM token to server: $e');
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'safechat_high_importance_channel', // id
            'High Importance Notifications', // title
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  void _handleDeepLink(Map<String, dynamic> data, GoRouter router) {
    final targetRoute = data['targetRoute'];
    if (targetRoute != null && targetRoute.toString().isNotEmpty) {
      router.push(targetRoute.toString());
    }
  }
}
