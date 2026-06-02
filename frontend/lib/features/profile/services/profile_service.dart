import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/user_profile.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(ref.watch(dioProvider));
});

class ProfileService {
  final Dio _dio;

  ProfileService(this._dio);

  Future<UserProfile> getProfile(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      return UserProfile.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<UserProfile> getCurrentUserProfile() async {
    try {
      final response = await _dio.get('/auth/me');
      return UserProfile.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load current profile: $e');
    }
  }

  Future<void> followUser(String userId) async {
    await _dio.post('/users/$userId/follow');
  }

  Future<void> unfollowUser(String userId) async {
    await _dio.delete('/users/$userId/follow');
  }

  Future<List<UserProfile>> getFollowers(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/followers');
      return (response.data['data'] as List).map((x) => UserProfile.fromJson(x)).toList();
    } catch (e) {
      throw Exception('Failed to load followers: $e');
    }
  }

  Future<List<UserProfile>> getFollowing(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/following');
      return (response.data['data'] as List).map((x) => UserProfile.fromJson(x)).toList();
    } catch (e) {
      throw Exception('Failed to load following: $e');
    }
  }
}
