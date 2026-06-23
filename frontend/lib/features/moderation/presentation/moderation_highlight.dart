import 'package:flutter/material.dart';

import '../data/moderation_models.dart';

/// Renders [text] with the flagged [matches] highlighted (red error swatch).
/// Spans that are out of range or overlap are handled defensively so a bad
/// span can never crash rendering.
class ModerationHighlightedText extends StatelessWidget {
  final String text;
  final List<ModerationMatch> matches;
  final TextStyle? baseStyle;

  const ModerationHighlightedText({
    super.key,
    required this.text,
    required this.matches,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    final base = baseStyle ?? Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
    return Text.rich(
      TextSpan(
        style: base,
        children: buildHighlightSpans(text: text, matches: matches, base: base, context: context),
      ),
    );
  }
}

/// Build the inline spans for [text], wrapping each in-range match in a
/// highlighted style. Matches are sorted by start and overlaps are skipped.
List<InlineSpan> buildHighlightSpans({
  required String text,
  required List<ModerationMatch> matches,
  required TextStyle base,
  required BuildContext context,
}) {
  final valid =
      matches.where((m) => m.start >= 0 && m.end > m.start && m.end <= text.length).toList()
        ..sort((a, b) => a.start.compareTo(b.start));

  if (valid.isEmpty) {
    return [TextSpan(text: text)];
  }

  final scheme = Theme.of(context).colorScheme;
  final highlightStyle = base.copyWith(
    color: scheme.onErrorContainer,
    backgroundColor: scheme.errorContainer,
    fontWeight: FontWeight.bold,
  );

  final spans = <InlineSpan>[];
  var cursor = 0;
  for (final match in valid) {
    final start = match.start < cursor ? cursor : match.start;
    if (start >= match.end) continue; // fully overlapped by a previous match
    if (start > cursor) {
      spans.add(TextSpan(text: text.substring(cursor, start)));
    }
    spans.add(TextSpan(text: text.substring(start, match.end), style: highlightStyle));
    cursor = match.end;
  }
  if (cursor < text.length) {
    spans.add(TextSpan(text: text.substring(cursor)));
  }
  return spans;
}
