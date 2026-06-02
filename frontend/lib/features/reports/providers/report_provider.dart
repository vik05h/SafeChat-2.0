import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report.dart';
import '../services/report_service.dart';

final reportProvider = StateNotifierProvider<ReportNotifier, AsyncValue<void>>((ref) {
  return ReportNotifier(ref.watch(reportServiceProvider));
});

class ReportNotifier extends StateNotifier<AsyncValue<void>> {
  final ReportService _reportService;

  ReportNotifier(this._reportService) : super(const AsyncData(null));

  Future<void> submitReport({
    required ReportTargetType targetType,
    required String targetId,
    required ReportReason reason,
    String? additionalInfo,
  }) async {
    state = const AsyncLoading();
    try {
      await _reportService.submitReport(
        targetType: targetType,
        targetId: targetId,
        reason: reason,
        additionalInfo: additionalInfo,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
