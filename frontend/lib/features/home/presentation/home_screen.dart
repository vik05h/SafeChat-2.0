import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../theme/theme_provider.dart';
import 'feed_view.dart';
import 'search_view.dart';
import 'create_post_view.dart';
import '../../chat/presentation/chat_list_view.dart';
import '../../profile/presentation/profile_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _views = const [
    FeedView(),
    SearchView(),
    CreatePostView(),
    ChatListView(),
    ProfileView(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navbarStyle = ref.watch(navbarStyleProvider);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      )
          .animate()
          .fadeIn(duration: 400.ms, curve: Curves.easeOut)
          .slideY(begin: 0.05, duration: 350.ms, curve: Curves.easeOutCubic),
      bottomNavigationBar: _buildNavbar(navbarStyle),
    );
  }

  Widget _buildNavbar(NavbarStyle style) {
    switch (style) {
      case NavbarStyle.floatingPill:
        return _buildFloatingPillNav();
      case NavbarStyle.hiddenLabels:
        return _buildStandardNav(labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected);
      case NavbarStyle.standard:
      default:
        return _buildStandardNav(labelBehavior: NavigationDestinationLabelBehavior.alwaysShow);
    }
  }

  Widget _buildStandardNav({required NavigationDestinationLabelBehavior labelBehavior}) {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: _onTabSelected,
      labelBehavior: labelBehavior,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.search_outlined),
          selectedIcon: Icon(Icons.search_rounded),
          label: 'Search',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle_rounded),
          label: 'Post',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble_rounded),
          label: 'Chat',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildFloatingPillNav() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFloatingPillItem(Icons.home_outlined, Icons.home_rounded, 0),
                _buildFloatingPillItem(Icons.search_outlined, Icons.search_rounded, 1),
                _buildFloatingPillItem(Icons.add_circle_outline, Icons.add_circle_rounded, 2),
                _buildFloatingPillItem(Icons.chat_bubble_outline, Icons.chat_bubble_rounded, 3),
                _buildFloatingPillItem(Icons.person_outline, Icons.person_rounded, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingPillItem(IconData icon, IconData selectedIcon, int index) {
    final isSelected = _currentIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
