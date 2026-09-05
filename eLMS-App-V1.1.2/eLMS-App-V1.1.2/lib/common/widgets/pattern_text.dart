import 'package:elms/common/widgets/animated_showmore_container.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PatternText extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;
  final void Function(String url)? onTapUrl;
  final bool readMore;
  final int readMoreMaxLines;
  final String? readMoreText;
  final String? readLessText;

  const PatternText({
    super.key,
    required this.text,
    this.baseStyle,
    this.onTapUrl,
    this.readMore = false,
    this.readMoreMaxLines = 3,
    this.readMoreText,
    this.readLessText,
  });

  @override
  Widget build(BuildContext context) {
    final TextSpan span = TextSpan(
      style: baseStyle ?? const TextStyle(color: Colors.black),
      children: _parseText(text),
    );

    if (readMore) {
      return AnimatedShowMore<TextSpan>(
        content: span,
        maxLines: readMoreMaxLines,
        buttonText: readMoreText,

        expandedButtonText: readLessText,
      );
    }

    return SelectableText.rich(span);
  }

  List<TextSpan> _parseText(String input) {
    final spans = <TextSpan>[];

    final regex = RegExp(
      r'(\*\*[^*]+\*\*|\*[^*]+\*|_[^_]+_|~[^~]+~|`[^`]+`|https?:\/\/[^\s]+|@\w+)',
      multiLine: true,
      unicode: true,
    );

    int lastIndex = 0;

    for (final match in regex.allMatches(input)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: input.substring(lastIndex, match.start)));
      }

      final token = match.group(0)!;

      if (_isWrapped(token, '**')) {
        spans.add(
          TextSpan(
            text: _unwrap(token, '**'),
            style: const TextStyle(fontWeight: .bold),
          ),
        );
      } else if (_isWrapped(token, '*')) {
        spans.add(
          TextSpan(
            text: _unwrap(token, '*'),
            style: const TextStyle(fontWeight: .bold),
          ),
        );
      } else if (_isWrapped(token, '_')) {
        spans.add(
          TextSpan(
            text: _unwrap(token, '_'),
            style: const TextStyle(fontStyle: .italic),
          ),
        );
      } else if (_isWrapped(token, '~')) {
        spans.add(
          TextSpan(
            text: _unwrap(token, '~'),
            style: const TextStyle(decoration: TextDecoration.lineThrough),
          ),
        );
      } else if (_isWrapped(token, '`')) {
        spans.add(
          TextSpan(
            text: _unwrap(token, '`'),
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        );
      } else if (token.startsWith('http')) {
        spans.add(
          TextSpan(
            text: token,
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => onTapUrl?.call(token),
          ),
        );
      } else if (token.startsWith('@')) {
        spans.add(
          TextSpan(
            text: token,
            style: const TextStyle(color: Colors.teal),
          ),
        );
      }

      lastIndex = match.end;
    }

    if (lastIndex < input.length) {
      spans.add(TextSpan(text: input.substring(lastIndex)));
    }

    return spans;
  }

  bool _isWrapped(String text, String wrapper) =>
      text.length >= wrapper.length * 2 &&
      text.startsWith(wrapper) &&
      text.endsWith(wrapper);

  String _unwrap(String text, String wrapper) =>
      text.substring(wrapper.length, text.length - wrapper.length);
}
