import 'package:flutter/material.dart';

class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final double radius;

  DottedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashLength = 3,
    this.gapLength = 3,
    this.radius = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rRect);
    final metrics = path.computeMetrics().first;

    double distance = 0;
    while (distance < metrics.length) {
      final currentLength = distance + dashLength < metrics.length
          ? dashLength
          : metrics.length - distance;

      canvas.drawPath(
        metrics.extractPath(distance, distance + currentLength),
        paint,
      );

      distance += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
