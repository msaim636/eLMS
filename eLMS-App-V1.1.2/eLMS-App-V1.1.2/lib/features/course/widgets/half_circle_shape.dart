import 'package:flutter/material.dart';

class HalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double topPadding = size.height * 0.66;
    const double curvature = 5;
    final path = Path();
    path.moveTo(0, topPadding);
    path.quadraticBezierTo(
      size.width / 2,
      size.height / curvature,
      size.width,
      topPadding,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
