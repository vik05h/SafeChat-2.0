import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../../core/network/dio_client.dart';
import '../../profile/models/user_profile.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(ref.watch(dioProvider));
});

class SettingsService {
  final Dio _dio;

  SettingsService(this._dio);

  Future<void> updatePrivacySettings({required bool isPrivate}) async {
    await _dio.put('/users/me/privacy', data: {'is_private': isPrivate});
  }

  Future<void> blockUser(String userId) async {
    await _dio.post('/users/$userId/block');
    FirebaseAnalytics.instance.logEvent(name: 'user_blocked');
  }

  Future<void> unblockUser(String userId) async {
    await _dio.delete('/users/$userId/block');
  }

  Future<void> muteUser(String userId) async {
    await _dio.post('/users/$userId/mute');
  }

  Future<void> deleteAccount() async {
    await _dio.delete('/users/me');
  }

  Future<void> logoutEverywhere() async {
    await _dio.post('/users/me/logout-all');
  }

  Future<List<UserProfile>> getBlockedUsers() async {
    try {
      final response = await _dio.get('/users/me/blocked');
      return (response.data['data'] as List).map((x) => UserProfile.fromJson(x)).toList();
    } catch (e) {
      throw Exception('Failed to load blocked users: $e');
    }
  }
}
