import 'package:dio/dio.dart';

/// A flagged term and its character span within the original text, returned by
/// the backend so the client can highlight exactly what tripped the filter.
class ModerationMatch {
  final String term;
  final String category;
  final int start;
  final int end;

  const ModerationMatch({
    required this.term,
    required this.category,
    required this.start,
    required this.end,
  });

  factory ModerationMatch.fromJson(Map<String, dynamic> json) {
    return ModerationMatch(
      term: json['term'] as String? ?? '',
      category: json['category'] as String? ?? '',
      start: (json['start'] as num?)?.toInt() ?? -1,
      end: (json['end'] as num?)?.toInt() ?? -1,
    );
  }
}

/// Raised when the backend flags content (HTTP 422 `MODERATION_FLAGGED`) and the
/// author has not yet opted into human verification. Carries the spans so the
/// UI can show the "this can't be uploaded" popup with the words highlighted.
class FlaggedContentException implements Exception {
  final List<ModerationMatch> matches;
  final String? reason;
  final String message;

  const FlaggedContentException({
    required this.matches,
    this.reason,
    this.message = 'This content was flagged by our safety filter.',
  });

  @override
  String toString() => message;
}

/// Parse a flagged-content error from an `{error: {...}}` envelope body.
/// Returns null if the body isn't a MODERATION_FLAGGED error.
FlaggedContentException? flaggedFromEnvelope(Object? data) {
  if (data is! Map) return null;
  final error = data['error'];
  if (error is! Map || error['code'] != 'MODERATION_FLAGGED') return null;
  final rawMatches = (error['matches'] as List?) ?? const [];
  final matches = rawMatches
      .whereType<Map>()
      .map((m) => ModerationMatch.fromJson(m.cast<String, dynamic>()))
      .toList();
  return FlaggedContentException(
    matches: matches,
    reason: error['reason'] as String?,
    message: error['message'] as String? ?? 'This content was flagged.',
  );
}

/// If [error] (typically a thrown [DioException]) represents a flagged-content
/// 422, return the parsed [FlaggedContentException]; otherwise null.
FlaggedContentException? flaggedFromError(Object error) {
  if (error is FlaggedContentException) return error;
  if (error is DioException && error.response?.statusCode == 422) {
    return flaggedFromEnvelope(error.response?.data);
  }
  return null;
}
