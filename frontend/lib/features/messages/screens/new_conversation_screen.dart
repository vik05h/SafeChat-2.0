import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_colors.dart';
import '../../search/providers/search_provider.dart';

class NewConversationScreen extends ConsumerStatefulWidget {
  const NewConversationScreen({super.key});

  @override
  ConsumerState<NewConversationScreen> createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends ConsumerState<NewConversationScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Message'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search for users...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.elevatedSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) {
                ref.read(searchTabProvider.notifier).state = 0; // Force users search
                ref.read(searchQueryProvider.notifier).state = val;
              },
            ),
          ),
        ),
      ),
      body: query.isEmpty
          ? const Center(child: Text('Type a username to start a conversation', style: TextStyle(color: AppColors.textSecondary)))
          : resultsAsync.when(
              data: (results) {
                if (results.isEmpty) return const Center(child: Text('No users found.'));
                
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
                            child: user.photoUrl.isEmpty ? const Icon(Icons.person) : null,
                          ),
                          title: Text(user.displayName),
                          subtitle: Text('@${user.username}'),
                          onTap: () {
                            // Clear search state and navigate to chat
                            ref.read(searchQueryProvider.notifier).state = '';
                            _searchController.clear();
                            // Use the standard conversation routing which creates doc on send
                            context.pushReplacementNamed('chat_detail', pathParameters: {'id': 'new_${user.id}'}, extra: user.displayName);
                          },
                        );
                      },
                      post: (post) => const SizedBox.shrink(), // Ignore posts here
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) {
                if (err.toString().contains('Cancelled')) return const SizedBox.shrink();
                return Center(child: Text('Error: $err'));
              },
            ),
    );
  }
}
