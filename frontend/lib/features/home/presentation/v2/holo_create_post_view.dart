import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../theme/dark_holo_colors.dart';

class HoloCreatePostView extends StatefulWidget {
  const HoloCreatePostView({super.key});

  @override
  State<HoloCreatePostView> createState() => _HoloCreatePostViewState();
}

class _HoloCreatePostViewState extends State<HoloCreatePostView>
    with SingleTickerProviderStateMixin {
  final _captionController = TextEditingController();
  late AnimationController _holdController;
  bool _isHolding = false;
  int _selectedImage = 3; // mock selected image seed

  final List<int> _gallerySeeds = [3, 7, 14, 21, 28, 33, 42, 50, 55, 61, 70, 82];

  @override
  void initState() {
    super.initState();
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onPost();
      }
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    _holdController.dispose();
    super.dispose();
  }

  void _startHold() {
    setState(() => _isHolding = true);
    _holdController.forward();
  }

  void _endHold() {
    if (_holdController.value < 1.0) {
      setState(() => _isHolding = false);
      _holdController.reverse();
    }
  }

  void _onPost() {
    // TODO: Call backend API for moderation & post creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚀 Post dropped! Under moderation review...'),
        backgroundColor: HoloColors.glowPurple,
      ),
    );
    _holdController.reset();
    setState(() => _isHolding = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HoloColors.bgVoid,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            child: Row(
              children: [
                const Text(
                  'Drop It',
                  style: TextStyle(
                    color: HoloColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                  ),
                ),
                const Spacer(),
                // Hold-to-Post button
                GestureDetector(
                  onTapDown: (_) => _startHold(),
                  onTapUp: (_) => _endHold(),
                  onTapCancel: _endHold,
                  child: AnimatedBuilder(
                    animation: _holdController,
                    builder: (context, child) {
                      return Container(
                        width: 72,
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: HoloColors.bgCard,
                          border: Border.all(color: HoloColors.glowPurple, width: 1.5),
                          boxShadow: _isHolding
                              ? [BoxShadow(color: HoloColors.glowPurple.withOpacity(0.4), blurRadius: 16)]
                              : null,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Fill progress
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: LinearProgressIndicator(
                                  value: _holdController.value,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation(
                                    HoloColors.glowPurple.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isHolding ? Icons.rocket_launch : Icons.near_me_rounded,
                                  color: HoloColors.glowPurple,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isHolding ? 'Hold' : 'Post',
                                  style: const TextStyle(
                                    color: HoloColors.glowPurple,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Preview image
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://picsum.photos/seed/$_selectedImage/600/800',
                      fit: BoxFit.cover,
                    ),
                    // Gradient bottom for caption overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                          ),
                        ),
                      ),
                    ),
                    // Floating caption input
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: TextField(
                        controller: _captionController,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Caption your drop...',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    // Quick options overlay (top right)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Column(
                        children: [
                          _OverlayIconBtn(icon: Icons.tune_rounded, onTap: () {}),
                          const SizedBox(height: 8),
                          _OverlayIconBtn(icon: Icons.face_retouching_natural, onTap: () {}),
                          const SizedBox(height: 8),
                          _OverlayIconBtn(icon: Icons.music_note_rounded, onTap: () {}),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().scale(
                    begin: const Offset(0.95, 0.95),
                    duration: 300.ms,
                    curve: Curves.easeOut,
                  ),
            ),
          ),

          const SizedBox(height: 12),

          // Image picker row
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _gallerySeeds.length,
              itemBuilder: (context, i) {
                final seed = _gallerySeeds[i];
                final isSelected = seed == _selectedImage;
                return GestureDetector(
                  onTap: () => setState(() => _selectedImage = seed),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 70,
                    height: 70,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? HoloColors.glowPurple : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: HoloColors.glowPurple.withOpacity(0.5), blurRadius: 10)]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        'https://picsum.photos/seed/$seed/150/150',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom action bar
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: HoloColors.bgCard.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: HoloColors.borderGlow),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _BarIconBtn(icon: Icons.photo_library_outlined, label: 'Gallery', onTap: () {}),
                      _BarIconBtn(icon: Icons.camera_alt_outlined, label: 'Camera', onTap: () {}),
                      _BarIconBtn(icon: Icons.videocam_outlined, label: 'Video', onTap: () {}),
                      _BarIconBtn(icon: Icons.location_on_outlined, label: 'Location', onTap: () {}),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _OverlayIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: 38,
            height: 38,
            color: Colors.black38,
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}

class _BarIconBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _BarIconBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: HoloColors.textSecondary, size: 22),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: HoloColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}
