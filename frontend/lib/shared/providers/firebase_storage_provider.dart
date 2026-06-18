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
  
  String gsUrl = rawUrl;
  if (rawUrl.startsWith('https://storage.googleapis.com/')) {
    gsUrl = rawUrl.replaceFirst('https://storage.googleapis.com/', 'gs://');
  }

  try {
    final ref = FirebaseStorage.instance.refFromURL(gsUrl);
    final downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    // If it fails (e.g. object not found), return original URL to let CachedNetworkImage
    // handle the error or fallback.
    return rawUrl;
  }
});
