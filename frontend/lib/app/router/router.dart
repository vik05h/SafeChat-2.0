import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/home/screens/home_shell.dart';
import '../../features/feed/screens/feed_screen.dart';
import '../../features/posts/screens/create_post_screen.dart';
import '../../features/messages/screens/chat_list_screen.dart';
import '../../features/messages/screens/chat_detail_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/safety/screens/safety_center_screen.dart';
import '../../features/safety/screens/appeals_screen.dart';
import '../../features/safety/screens/community_guidelines_screen.dart';
import '../../features/notifications/screens/notification_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/blocked_users_screen.dart';
import '../../features/profile/screens/follow_list_screen.dart';
import '../../features/messages/screens/new_conversation_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final analytics = FirebaseAnalytics.instance;

  return GoRouter(
    initialLocation: '/login',
    observers: [
      FirebaseAnalyticsObserver(analytics: analytics),
    ],
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/create_post',
        name: 'create_post',
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: '/chat_detail/:id',
        name: 'chat_detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final otherUserName = state.extra as String? ?? 'User';
          return ChatDetailScreen(conversationId: id, otherUserName: otherUserName);
        },
      ),
      GoRoute(
        path: '/profile/:id',
        name: 'profile',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'me';
          return ProfileScreen(userId: id);
        },
      ),
      GoRoute(
        path: '/appeals',
        name: 'appeals',
        builder: (context, state) => const AppealsScreen(),
      ),
      GoRoute(
        path: '/community_guidelines',
        name: 'community_guidelines',
        builder: (context, state) => const CommunityGuidelinesScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/blocked_users',
        name: 'blocked_users',
        builder: (context, state) => const BlockedUsersScreen(),
      ),
      GoRoute(
        path: '/follow_list',
        name: 'follow_list',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return FollowListScreen(userId: extra['userId'], type: extra['type']);
        },
      ),
      GoRoute(
        path: '/new_conversation',
        name: 'new_conversation',
        builder: (context, state) => const NewConversationScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return HomeShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const FeedScreen(),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/messages',
            name: 'messages',
            builder: (context, state) => const ChatListScreen(),
          ),
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'my_profile',
            builder: (context, state) => const ProfileScreen(userId: 'me'),
          ),
          GoRoute(
            path: '/safety_center',
            name: 'safety_center',
            builder: (context, state) => const SafetyCenterScreen(),
          ),
        ],
      ),
    ],
  );
});
