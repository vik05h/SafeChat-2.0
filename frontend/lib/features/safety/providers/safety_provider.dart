import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/safety_stats.dart';
import '../models/appeal.dart';
import '../services/safety_service.dart';

final safetyStatsProvider = FutureProvider.autoDispose<SafetyStats>((ref) async {
  return ref.watch(safetyServiceProvider).getSafetyStats();
});

final appealsProvider = FutureProvider.autoDispose<List<Appeal>>((ref) async {
  return ref.watch(safetyServiceProvider).getAppeals();
});
