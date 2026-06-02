import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';

final notificationProvider = StateNotifierProvider<NotificationNotifier, AsyncValue<List<AppNotification>>>((ref) {
  return NotificationNotifier(ref.watch(notificationServiceProvider))..loadNotifications();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final state = ref.watch(notificationProvider);
  return state.maybeWhen(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});

class NotificationNotifier extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final NotificationService _service;

  NotificationNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final notifications = await _service.getNotifications();
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final currentList = state.value;
    if (currentList == null) return;

    final newList = currentList.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    state = AsyncValue.data(newList);

    try {
      await _service.markAsRead(notificationId);
    } catch (e) {
      // Revert if failed
      state = AsyncValue.data(currentList);
    }
  }

  Future<void> markAllAsRead() async {
    final currentList = state.value;
    if (currentList == null) return;

    final newList = currentList.map((n) => n.copyWith(isRead: true)).toList();
    state = AsyncValue.data(newList);

    try {
      await _service.markAllAsRead();
    } catch (e) {
      state = AsyncValue.data(currentList);
    }
  }
}
