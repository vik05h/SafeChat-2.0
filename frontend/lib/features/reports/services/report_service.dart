import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/report.dart';

final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService(ref.watch(dioProvider));
});

class ReportService {
  final Dio _dio;

  ReportService(this._dio);

  Future<void> submitReport({
    required ReportTargetType targetType,
    required String targetId,
    required ReportReason reason,
    String? additionalInfo,
  }) async {
    try {
      await _dio.post('/reports', data: {
        'target_type': targetType.name,
        'target_id': targetId,
        'reason': reason.name,
        if (additionalInfo != null && additionalInfo.isNotEmpty) 'additional_info': additionalInfo,
      });
    } catch (e) {
      throw Exception('Failed to submit report: $e');
    }
  }
}
