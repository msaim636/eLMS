import 'package:elms/common/widgets/custom_button.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimatedShowMore<T> extends StatefulWidget {
  final T content;
  final int maxLines;
  final int maxItems;
  final String? buttonText;
  final String? expandedButtonText;
  final TextStyle? textStyle;
  final Color? textColor;
  final double buttonHeight;
  final EdgeInsetsGeometry? padding;

  const AnimatedShowMore({
    super.key,
    required this.content,
    this.maxLines = 5,
    this.maxItems = 4,
    this.buttonText,
    this.expandedButtonText,
    this.textStyle,
    this.textColor,
    this.buttonHeight = 32,
    this.padding,
  });

  @override
  State<AnimatedShowMore> createState() => _AnimatedShowMoreState();
}

class _AnimatedShowMoreState extends State<AnimatedShowMore>
    with SingleTickerProviderStateMixin {
  late final bool isText = widget.content is String;
  late final bool isTextSpan =
      widget.content is TextSpan || widget.content is InlineSpan;
  late final bool isList = widget.content is List;
  bool _isExpanded = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget _buildTextContent() {
    final text = widget.content as String;
    final style = widget.textStyle ?? TextStyle(fontSize: context.font.small);

    return LayoutBuilder(
      builder: (context, constraints) {
        final textSpan = TextSpan(text: text, style: style);
        final textPainter = TextPainter(
          text: textSpan,
          maxLines: widget.maxLines,
          textDirection: Directionality.of(context),
        );

        final maxWidth = constraints.maxWidth.isInfinite
            ? MediaQuery.of(context).size.width
            : constraints.maxWidth;

        textPainter.layout(maxWidth: maxWidth);

        final isTextOverflowing = textPainter.didExceedMaxLines;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              alignment: Alignment.topLeft,
              child: Text(
                text,
                style: style,
                maxLines: _isExpanded ? null : widget.maxLines,
                overflow: _isExpanded ? null : TextOverflow.ellipsis,
              ),
            ),
            if (isTextOverflowing)
              Align(
                alignment: Alignment.centerLeft,
                child: CustomButton(
                  onPressed: _toggleExpand,
                  padding: EdgeInsets.zero,
                  title: _isExpanded
                      ? (widget.expandedButtonText ?? AppLabels.showLess.tr)
                      : (widget.buttonText ?? AppLabels.showMore.tr),
                  height: widget.buttonHeight,
                  backgroundColor: Colors.transparent,
                  borderColor: Colors.transparent,
                  textColor: widget.textColor ?? context.color.primary,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTextSpanContent() {
    final textSpan = widget.content as InlineSpan;

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: textSpan,
          maxLines: widget.maxLines,
          textDirection: Directionality.of(context),
        );

        final maxWidth = constraints.maxWidth.isInfinite
            ? MediaQuery.of(context).size.width
            : constraints.maxWidth;

        textPainter.layout(maxWidth: maxWidth);

        final isTextOverflowing = textPainter.didExceedMaxLines;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              alignment: Alignment.topLeft,
              child: Text.rich(
                textSpan,
                maxLines: _isExpanded ? null : widget.maxLines,
                overflow: _isExpanded ? null : TextOverflow.ellipsis,
              ),
            ),
            if (isTextOverflowing)
              Align(
                alignment: Alignment.centerLeft,
                child: CustomButton(
                  onPressed: _toggleExpand,
                  padding: EdgeInsets.zero,
                  title: _isExpanded
                      ? (widget.expandedButtonText ?? AppLabels.showLess.tr)
                      : (widget.buttonText ?? AppLabels.showMore.tr),
                  height: widget.buttonHeight,
                  backgroundColor: Colors.transparent,
                  borderColor: Colors.transparent,
                  textColor: widget.textColor ?? context.color.primary,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildListContent() {
    final list = widget.content as List;
    final isListOverflowing = list.length > widget.maxItems;

    return Column(
      crossAxisAlignment: .start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          alignment: .topLeft,
          child: Column(
            children: _isExpanded
                ? list.map((item) => item as Widget).toList()
                : list
                      .take(widget.maxItems)
                      .map((item) => item as Widget)
                      .toList(),
          ),
        ),
        if (isListOverflowing)
          Align(
            alignment: .centerLeft,
            child: CustomButton(
              borderColor: Colors.transparent,
              onPressed: _toggleExpand,
              padding: .zero,
              title: _isExpanded
                  ? (widget.expandedButtonText ?? AppLabels.showLess.tr)
                  : (widget.buttonText ?? AppLabels.showMore.tr),
              height: widget.buttonHeight,
              backgroundColor: Colors.transparent,
              textColor: widget.textColor ?? context.color.primary,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? .zero,
      child: isText
          ? _buildTextContent()
          : isTextSpan
          ? _buildTextSpanContent()
          : isList
          ? _buildListContent()
          : throw ArgumentError(
              'Content must be either String, TextSpan or List',
            ), //Development time error message. Not needed in production so no need to translate
    );
  }
}
