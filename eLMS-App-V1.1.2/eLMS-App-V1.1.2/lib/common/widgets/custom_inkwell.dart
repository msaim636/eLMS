import 'package:flutter/material.dart';

class CustomInkWell extends StatefulWidget {
  const CustomInkWell({
    required this.onTap,
    required this.color,
    required this.child,
    super.key,
    this.radius = 0,
  });
  final VoidCallback? onTap;
  final Color color;
  final Widget child;
  final double radius;

  @override
  State<CustomInkWell> createState() => _CustomInkWellState();
}

class _CustomInkWellState extends State<CustomInkWell> {
  @override
  Widget build(final BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(widget.radius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(widget.radius),
          child: widget.child,
        ),
      ),
    );
  }
}
