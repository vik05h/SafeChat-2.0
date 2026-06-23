import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';

/// True when the signed-in user carries the `admin` Firebase custom claim
/// (set via backend/scripts/set_admin.py). Gates the moderation portal entry.
final isAdminProvider = FutureProvider.autoDispose<bool>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;
  // Force-refresh so a just-granted `admin` claim is picked up without
  // requiring the user to sign out and back in.
  final token = await user.getIdTokenResult(true);
  return token.claims?['admin'] == true;
});

/// Pending moderation-queue items (admin only) — GET /admin/moderation/queue.
final moderationQueueProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/api/v1/admin/moderation/queue');
      final data = response.data;
      final items = data is Map ? (data['data']?['items'] as List?) : null;
      return (items ?? const [])
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    });
