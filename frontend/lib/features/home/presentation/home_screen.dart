import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'feed_view.dart';
import 'search_view.dart';
import 'create_post_view.dart';
import '../../chat/presentation/chat_list_view.dart';
import '../../profile/presentation/profile_view.dart';
import 'dialer_nav.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _views = [
    const FeedView(),
    const SearchView(),
    const CreatePostView(),
    const ChatListView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _views,
          ).animate().fadeIn(duration: 800.ms, curve: Curves.easeOut).slideY(begin: 0.1, duration: 600.ms, curve: Curves.easeOutCubic),
          
          DialerGestureNav(
            currentIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}
