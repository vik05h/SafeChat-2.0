import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class HighlightSyntax extends md.InlineSyntax {
  HighlightSyntax() : super(r'==([^=]+)==');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final element = md.Element.text('highlight', match[1]!);
    parser.addNode(element);
    return true;
  }
}

class HighlightBuilder extends MarkdownElementBuilder {
  final BuildContext context;
  HighlightBuilder(this.context);

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.yellow.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        element.textContent,
        style: preferredStyle?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
