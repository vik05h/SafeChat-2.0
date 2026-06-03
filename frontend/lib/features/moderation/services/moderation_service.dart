import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../../../core/network/dio_client.dart';
import '../models/moderation_result.dart';

final moderationServiceProvider = Provider<ModerationService>((ref) {
  return ModerationService(ref.watch(dioProvider));
});

class ModerationService {
  final Dio _dio;

  ModerationService(this._dio);

  Future<ModerationResult> analyzeContent(String text) async {
    try {
      final directResponse = await _dio.post('/moderation/analyze', data: {
        'text': text,
      });

      final String status = directResponse.data['status']?.toString().toUpperCase() ?? 'SAFE';
      
      return ModerationResult(
        status: status == 'BLOCKED' 
            ? ModerationStatus.blocked 
            : status == 'WARNING' 
                ? ModerationStatus.warning 
                : ModerationStatus.safe,
        category: directResponse.data['category'],
        reason: directResponse.data['reason'],
      );
    } catch (e, st) {
      if (e is DioException && e.response?.statusCode == 422) {
         // Moderation blocked via normal endpoint usually returns 422
         return ModerationResult(
           status: ModerationStatus.blocked,
           reason: 'Content blocked by moderation cascade',
         );
      }
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'Moderation API failure');
      rethrow;
    }
  }
}
