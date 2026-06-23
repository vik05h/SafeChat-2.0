// frontend/lib/shared/widgets/dp_viewer.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/firebase_storage_provider.dart';

void showDpViewer(BuildContext context, WidgetRef ref, String imageUrl) {
  if (imageUrl.isEmpty) return;
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      pageBuilder: (ctx, animation, _) => _DpViewerPage(imageUrl: imageUrl),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

class _DpViewerPage extends ConsumerWidget {
  final String imageUrl;
  const _DpViewerPage({required this.imageUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final diameter = size.width * 0.85;
    final asyncUrl = ref.watch(firebaseImageUrlProvider(imageUrl));

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: asyncUrl.when(
            data: (url) => InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipOval(
                child: SizedBox(
                  width: diameter,
                  height: diameter,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                    errorWidget: (_, _, _) => Container(
                      color: Colors.grey[900],
                      child: const Icon(
                        Icons.person,
                        color: Colors.white38,
                        size: 80,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            loading: () => const CircularProgressIndicator(color: Colors.white),
            error: (_, _) => Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[900],
              ),
              child: const Icon(Icons.person, color: Colors.white38, size: 80),
            ),
          ),
        ),
      ),
    );
  }
}
