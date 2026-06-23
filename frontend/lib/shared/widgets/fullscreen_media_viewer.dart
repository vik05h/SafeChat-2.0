// frontend/lib/shared/widgets/fullscreen_media_viewer.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/firebase_storage_provider.dart';

class FullscreenMediaViewer extends ConsumerStatefulWidget {
  final List<String> urls;
  final int initialIndex;

  const FullscreenMediaViewer({
    super.key,
    required this.urls,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<FullscreenMediaViewer> createState() =>
      _FullscreenMediaViewerState();
}

class _FullscreenMediaViewerState extends ConsumerState<FullscreenMediaViewer> {
  late final PageController _pageController;
  late int _currentPage;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Draggable + zoomable page view
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (d) {
              if (d.delta.dy > 0) setState(() => _dragOffset += d.delta.dy);
            },
            onVerticalDragEnd: (d) {
              if (_dragOffset > 120 || (d.primaryVelocity ?? 0) > 600) {
                Navigator.of(context).pop();
              } else {
                setState(() => _dragOffset = 0);
              }
            },
            onVerticalDragCancel: () => setState(() => _dragOffset = 0),
            child: Transform.translate(
              offset: Offset(0, _dragOffset),
              child: Opacity(
                opacity: (1.0 - _dragOffset / 400).clamp(0.3, 1.0),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.urls.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final asyncUrl = ref.watch(
                      firebaseImageUrlProvider(widget.urls[index]),
                    );
                    return asyncUrl.when(
                      data: (resolvedUrl) => InteractiveViewer(
                        minScale: 0.8,
                        maxScale: 5.0,
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl: resolvedUrl,
                            fit: BoxFit.contain,
                            placeholder: (_, _) => const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (_, _, _) => const Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white38,
                              size: 64,
                            ),
                          ),
                        ),
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      error: (_, _) => const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white38,
                          size: 64,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Top bar: close + page counter
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  if (widget.urls.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentPage + 1} / ${widget.urls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  // Balance the row
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // Bottom dot indicators (multi-image)
          if (widget.urls.length > 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.urls.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

          // Swipe-down hint at the bottom
          Positioned(
            bottom: widget.urls.length > 1 ? 12 : 32,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white38,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  'Swipe down to close',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
