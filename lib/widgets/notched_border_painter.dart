import 'package:flutter/material.dart';

class NotchedBorderPainter extends CustomPainter {
  final double radius;
  final double notchMargin;
  final Color borderColor;
  final double strokeWidth;

  NotchedBorderPainter({
    this.radius = 18,
    this.notchMargin = 10,
    this.borderColor = Colors.grey,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = borderColor;

    final fabRadius = 23.0;
    final centerX = size.width / 2;

    final notchDepth = fabRadius + notchMargin;
    final notchWidth = fabRadius * 2.2 + notchMargin * 2;

    final path = Path();

    // ─── TOP LEFT ─────────────────────────────
    path.moveTo(radius, 0);
    path.lineTo(centerX - notchWidth / 2, 0);

    // ─── CURVED NOTCH ─────────────────────────

    final notchStartX = centerX - notchWidth / 2;
    final notchEndX = centerX + notchWidth / 2;

    path.cubicTo(
      notchStartX + fabRadius * 0.3,
      0, // smooth entry
      centerX - fabRadius * 1.1,
      notchDepth, // left dip control
      centerX,
      notchDepth, // bottom center
    );

    path.cubicTo(
      centerX + fabRadius * 1.1,
      notchDepth, // right dip control
      notchEndX - fabRadius * 0.3,
      0, // smooth exit
      notchEndX,
      0,
    );

    // ─── TOP RIGHT ────────────────────────────
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(
      Offset(size.width, radius),
      radius: Radius.circular(radius),
    );

    // ─── RIGHT ────────────────────────────────
    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(
      Offset(size.width - radius, size.height),
      radius: Radius.circular(radius),
    );

    // ─── BOTTOM ───────────────────────────────
    path.lineTo(radius, size.height);
    path.arcToPoint(
      Offset(0, size.height - radius),
      radius: Radius.circular(radius),
    );

    // ─── LEFT ─────────────────────────────────
    path.lineTo(0, radius);
    path.arcToPoint(Offset(radius, 0), radius: Radius.circular(radius));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}