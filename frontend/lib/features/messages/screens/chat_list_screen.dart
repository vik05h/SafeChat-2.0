import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../app/theme/app_colors.dart';
import '../providers/chat_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square),
            onPressed: () {
              context.pushNamed('new_conversation');
            },
          ),
        ],
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return const Center(child: Text('No messages yet.'));
          }
          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final conv = conversations[index];
              // Assuming 1-on-1 chats for now, find the "other" user
              final otherUserId = conv.participants.firstWhere(
                  (id) => id != 'CURRENT_USER_ID', // Replace with actual current user ID check
                  orElse: () => conv.participants.first);
              
              final otherUserName = conv.participantNames[otherUserId] ?? 'Unknown';
              final otherUserAvatar = conv.participantAvatars[otherUserId] ?? '';
              final unreadCount = conv.unreadCounts['CURRENT_USER_ID'] ?? 0;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: otherUserAvatar.isNotEmpty 
                      ? CachedNetworkImageProvider(otherUserAvatar)
                      : null,
                  backgroundColor: AppColors.border,
                  child: otherUserAvatar.isEmpty 
                      ? const Icon(Icons.person, color: AppColors.textSecondary)
                      : null,
                ),
                title: Text(otherUserName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  conv.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeago.format(conv.lastMessageTime),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (unreadCount > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryOrange,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  context.pushNamed('chat_detail', pathParameters: {'id': conv.id}, extra: otherUserName);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading chats: $err')),
      ),
    );
  }
}
