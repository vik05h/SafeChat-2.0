import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../../core/network/dio_client.dart';
import '../models/safety_stats.dart';
import '../models/appeal.dart';

final safetyServiceProvider = Provider<SafetyService>((ref) {
  return SafetyService(ref.watch(dioProvider));
});

class SafetyService {
  final Dio _dio;

  SafetyService(this._dio);

  Future<SafetyStats> getSafetyStats() async {
    try {
      final response = await _dio.get('/safety/stats');
      return SafetyStats.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load safety stats: $e');
    }
  }

  Future<List<Appeal>> getAppeals() async {
    try {
      final response = await _dio.get('/safety/appeals');
      final List data = response.data['data'] ?? [];
      return data.map((json) => Appeal.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load appeals: $e');
    }
  }

  Future<void> submitAppeal(String contentId, String reason) async {
    await _dio.post('/safety/appeals', data: {
      'content_id': contentId,
      'reason': reason,
    });
    FirebaseAnalytics.instance.logEvent(name: 'appeal_created');
  }
}
