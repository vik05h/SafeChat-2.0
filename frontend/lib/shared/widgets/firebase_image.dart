import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/firebase_storage_provider.dart';

class FirebaseCachedNetworkImage extends ConsumerWidget {
  final String imageUrl;
  final BoxFit? fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;

  const FirebaseCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (imageUrl.isEmpty) {
      return errorWidget?.call(context, imageUrl, 'Empty URL') ?? const SizedBox.shrink();
    }

    final asyncUrl = ref.watch(firebaseImageUrlProvider(imageUrl));

    return asyncUrl.when(
      data: (resolvedUrl) {
        return CachedNetworkImage(
          imageUrl: resolvedUrl,
          fit: fit,
          placeholder: placeholder,
          errorWidget: errorWidget,
        );
      },
      loading: () => placeholder?.call(context, imageUrl) ?? const Center(child: CircularProgressIndicator()),
      error: (e, _) => errorWidget?.call(context, imageUrl, e) ?? const Center(child: Icon(Icons.broken_image_outlined)),
    );
  }
}

class FirebaseImageProviderWrapper {
  /// A helper function to use with `backgroundImage` like CircleAvatar
  static ImageProvider? getProvider(WidgetRef ref, String rawUrl) {
    if (rawUrl.isEmpty) return null;
    final asyncUrl = ref.watch(firebaseImageUrlProvider(rawUrl));
    return asyncUrl.when(
      data: (url) => CachedNetworkImageProvider(url),
      loading: () => null, // Will just show background color
      error: (_, __) => null,
    );
  }
}
