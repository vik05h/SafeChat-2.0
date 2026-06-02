import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../app/theme/app_colors.dart';
import '../providers/search_provider.dart';
import '../models/search_result.dart';
import '../../profile/models/user_profile.dart';
import '../../../shared/widgets/post_card.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final tab = ref.watch(searchTabProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Search SafeChat...',
            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.elevatedSurface,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
        ),
        bottom: query.isNotEmpty
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => ref.read(searchTabProvider.notifier).state = 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: tab == 0 ? AppColors.primaryOrange : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Users',
                              style: TextStyle(
                                color: tab == 0 ? AppColors.primaryOrange : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => ref.read(searchTabProvider.notifier).state = 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: tab == 1 ? AppColors.primaryOrange : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Posts',
                              style: TextStyle(
                                color: tab == 1 ? AppColors.primaryOrange : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
      body: query.isEmpty ? _buildDiscoveryView(context, ref) : _buildSearchResults(context, ref),
    );
  }

  Widget _buildDiscoveryView(BuildContext context, WidgetRef ref) {
    final suggestedAsync = ref.watch(suggestedUsersProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Suggested Users', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          suggestedAsync.when(
            data: (users) {
              if (users.isEmpty) return const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('No suggestions available.'));
              return SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _buildSuggestedUserCard(context, user);
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Failed to load suggestions')),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedUserCard(BuildContext context, UserProfile user) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.elevatedSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: user.photoUrl.isNotEmpty ? CachedNetworkImageProvider(user.photoUrl) : null,
            backgroundColor: AppColors.border,
            child: user.photoUrl.isEmpty ? const Icon(Icons.person) : null,
          ),
          const SizedBox(height: 8),
          Text(
            user.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${user.safetyScore}% Safety',
            style: const TextStyle(fontSize: 10, color: AppColors.success),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(searchResultsProvider);

    return resultsAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return const Center(child: Text('No results found.'));
        }
        
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return result.when(
              user: (user) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.photoUrl.isNotEmpty ? CachedNetworkImageProvider(user.photoUrl) : null,
                    backgroundColor: AppColors.border,
                  ),
                  title: Text(user.displayName),
                  subtitle: Text('@${user.username}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Safe: ${user.safetyScore}%', style: const TextStyle(color: AppColors.success, fontSize: 12)),
                  ),
                  onTap: () {
                    context.pushNamed('profile', pathParameters: {'id': user.id});
                  },
                );
              },
              post: (post) {
                return PostCard(post: post);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) {
        if (e.toString().contains('Cancelled')) return const SizedBox.shrink(); // Ignore debounce cancellations
        return Center(child: Text('Error: $e'));
      },
    );
  }
}
