import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/theme_provider.dart';
import 'feed_view.dart';
import 'search_view.dart';
import 'create_post_view.dart';
import '../../chat/presentation/chat_list_view.dart';
import '../../profile/presentation/profile_view.dart';
import 'dialer_nav.dart';

// Dark Holo v2 views
import 'v2/holo_feed_view.dart';
import 'v2/holo_search_view.dart';
import 'v2/holo_create_post_view.dart';
import '../../chat/presentation/v2/holo_chat_list_view.dart';
import '../../profile/presentation/v2/holo_profile_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  List<Widget> _getViews(AppThemeMode theme) {
    if (theme == AppThemeMode.darkHolo) {
      return const [
        HoloFeedView(),
        HoloSearchView(),
        HoloCreatePostView(),
        HoloChatListView(),
        HoloProfileView(),
      ];
    }
    // Classic views for Material 3 & Neobrutalism
    return const [
      FeedView(),
      SearchView(),
      CreatePostView(),
      ChatListView(),
      ProfileView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final views = _getViews(theme);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: views,
          )
              .animate()
              .fadeIn(duration: 400.ms, curve: Curves.easeOut)
              .slideY(begin: 0.05, duration: 350.ms, curve: Curves.easeOutCubic),

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
