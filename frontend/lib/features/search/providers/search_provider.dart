import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_result.dart';
import '../services/search_service.dart';
import '../../profile/models/user_profile.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final searchTabProvider = StateProvider<int>((ref) => 0); // 0 = Users, 1 = Posts

final suggestedUsersProvider = FutureProvider.autoDispose<List<UserProfile>>((ref) async {
  return ref.watch(searchServiceProvider).getSuggestedUsers();
});

final searchResultsProvider = FutureProvider.autoDispose<List<SearchResult>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final tab = ref.watch(searchTabProvider);
  
  if (query.trim().isEmpty) return [];

  // Implement Debouncing using Riverpod's Future cancellation/delay mechanism
  var didDispose = false;
  ref.onDispose(() => didDispose = true);
  await Future.delayed(const Duration(milliseconds: 500));
  if (didDispose) throw Exception('Cancelled');

  final service = ref.watch(searchServiceProvider);
  if (tab == 0) {
    return await service.searchUsers(query);
  } else {
    return await service.searchPosts(query);
  }
});
