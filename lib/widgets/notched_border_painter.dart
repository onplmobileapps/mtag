import 'package:flutter/material.dart';

class NotchedBorderPainter extends CustomPainter {
  final double cornerRadius;
  final double notchMargin;
  final Color borderColor;
  final Color notchColor;
  final double strokeWidth;

  NotchedBorderPainter({
    this.cornerRadius = 16,
    this.notchMargin = 6,
    this.borderColor = Colors.grey,
    this.notchColor = Colors.grey,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fabRadius = 28.0;
    final centerX = size.width / 2;
    final notchDepth = 20.0; // Reduced depth for subtle curve

    // Moderate width for visible curve
    final notchWidth = fabRadius * 2.5;

    final Paint paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Start at top-left, after the corner
    path.moveTo(cornerRadius, 0);

    // Top line to notch start
    final pStart = Offset(centerX - (notchWidth / 2), 0);
    path.lineTo(pStart.dx, pStart.dy);

    // Create notch with clear curve
    final pBottom = Offset(centerX, notchDepth);
    final pEnd = Offset(centerX + (notchWidth / 2), 0);

    // Downward curve with moderate smoothness
    path.cubicTo(
      pStart.dx + (notchWidth * 0.15), 0,              // Start control
      pBottom.dx - (notchWidth * 0.35), pBottom.dy,    // Bottom approach
      pBottom.dx, pBottom.dy,                          // Bottom point
    );

    // Upward curve back to top
    path.cubicTo(
      pBottom.dx + (notchWidth * 0.35), pBottom.dy,    // Bottom exit
      pEnd.dx - (notchWidth * 0.15), 0,                // Top approach
      pEnd.dx, 0,                                      // End point
    );

    // Top line to top-right corner
    path.lineTo(size.width - cornerRadius, 0);

    // Top-right corner
    path.quadraticBezierTo(
      size.width, 0,
      size.width, cornerRadius,
    );

    // Right edge
    path.lineTo(size.width, size.height - cornerRadius);

    // Bottom-right corner
    path.quadraticBezierTo(
      size.width, size.height,
      size.width - cornerRadius, size.height,
    );

    // Bottom edge
    path.lineTo(cornerRadius, size.height);

    // Bottom-left corner
    path.quadraticBezierTo(
      0, size.height,
      0, size.height - cornerRadius,
    );

    // Left edge
    path.lineTo(0, cornerRadius);

    // Top-left corner
    path.quadraticBezierTo(
      0, 0,
      cornerRadius, 0,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant NotchedBorderPainter oldDelegate) {
    return oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.notchMargin != notchMargin ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.notchColor != notchColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}