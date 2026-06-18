import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A family provider that takes a raw GCS URL (https://storage.googleapis.com/...)
/// or gs:// URL and returns a temporary signed download token URL via Firebase Storage.
final firebaseImageUrlProvider = FutureProvider.family<String, String>((ref, rawUrl) async {
  if (rawUrl.isEmpty) return '';
  
  if (rawUrl.startsWith('http') && !rawUrl.startsWith('https://storage.googleapis.com/')) {
    // It's already a public URL not from our bucket (e.g. Google avatar)
    return rawUrl;
  }
  
  try {
    if (rawUrl.startsWith('https://storage.googleapis.com/')) {
      // If it's already a signed URL from the backend, just return it directly
      if (rawUrl.contains('Signature=') || rawUrl.contains('X-Goog-Signature=')) {
        return rawUrl;
      }
      
      final withoutDomain = rawUrl.replaceFirst('https://storage.googleapis.com/', '');
      final parts = withoutDomain.split('/');
      if (parts.length > 1) {
        // Skip bucket name
        final path = parts.skip(1).join('/');
        return await FirebaseStorage.instance.ref().child(path).getDownloadURL().timeout(const Duration(seconds: 3));
      }
    }

    String gsUrl = rawUrl;
    if (rawUrl.startsWith('https://storage.googleapis.com/')) {
      gsUrl = rawUrl.replaceFirst('https://storage.googleapis.com/', 'gs://');
    }

    final storageRef = FirebaseStorage.instance.refFromURL(gsUrl);
    final downloadUrl = await storageRef.getDownloadURL().timeout(const Duration(seconds: 3));
    return downloadUrl;
  } catch (e) {
    // If it fails (e.g. object not found), throw so the errorWidget can handle it gracefully.
    // Returning the raw URL for private buckets causes HTTP 403 exceptions in CachedNetworkImage.
    throw Exception('Storage error: $e');
  }
});
