import 'dart:ui';
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
    if (index == 2) {
      // Trigger the Create Post Bottom Sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const CreatePostView(),
      );
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navbarStyle = ref.watch(navbarStyleProvider);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _views)
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
        return _buildStandardNav(
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        );
      case NavbarStyle.standard:
        return _buildStandardNav(
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        );
    }
  }

  Widget _buildStandardNav({
    required NavigationDestinationLabelBehavior labelBehavior,
  }) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: NavigationBar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.6),
          elevation: 0,
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
        ),
      ),
    );
  }

  Widget _buildFloatingPillNav() {
    final colorScheme = Theme.of(context).colorScheme;

    // Map index 0..4 to alignment x: -1.0..1.0
    final alignmentX = -1.0 + (_currentIndex * 0.5);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Container(
          height: 64, // fixed height for consistent stack sizing
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Active Background Pill
              AnimatedAlign(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                alignment: Alignment(alignmentX, 0),
                child: FractionallySizedBox(
                  widthFactor: 1 / 5, // 5 items
                  heightFactor: 1.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ),
              // The Icons Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFloatingPillItem(
                    Icons.home_outlined,
                    Icons.home_rounded,
                    0,
                  ),
                  _buildFloatingPillItem(
                    Icons.search_outlined,
                    Icons.search_rounded,
                    1,
                  ),
                  _buildFloatingPillItem(
                    Icons.add_circle_outline,
                    Icons.add_circle_rounded,
                    2,
                  ),
                  _buildFloatingPillItem(
                    Icons.chat_bubble_outline,
                    Icons.chat_bubble_rounded,
                    3,
                  ),
                  _buildFloatingPillItem(
                    Icons.person_outline,
                    Icons.person_rounded,
                    4,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingPillItem(
    IconData icon,
    IconData selectedIcon,
    int index,
  ) {
    final isSelected = _currentIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              isSelected ? selectedIcon : icon,
              key: ValueKey<bool>(isSelected),
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
