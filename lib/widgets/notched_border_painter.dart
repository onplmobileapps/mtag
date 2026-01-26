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
    final fabRadius = 22.5;
    final centerX = size.width / 2;
    final notchDepth = fabRadius + notchMargin;
    final notchWidth = fabRadius * 2.8;

    // Create main border paint (grey color)
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = borderColor
      ..strokeWidth = strokeWidth;

    // Create notch paint
    final notchPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = notchColor
      ..strokeWidth = strokeWidth;

    // ─── DRAW HORIZONTAL TOP LINES ────────────
    // Left horizontal line (from left corner to notch start)
    canvas.drawLine(
      Offset(cornerRadius, 0),
      Offset(centerX - notchWidth / 2, 0),
      borderPaint,
    );

    // Right horizontal line (from notch end to right corner)
    canvas.drawLine(
      Offset(centerX + notchWidth / 2, 0),
      Offset(size.width - cornerRadius, 0),
      borderPaint,
    );

    // ─── DRAW NOTCH CURVE ─────────────────────
    final notchPath = Path();

    // Start notch from left connection point
    notchPath.moveTo(centerX - notchWidth / 2, 0);

    // Draw the notch curve
    notchPath.quadraticBezierTo(
      centerX - fabRadius,
      notchDepth,
      centerX,
      notchDepth,
    );

    notchPath.quadraticBezierTo(
      centerX + fabRadius,
      notchDepth,
      centerX + notchWidth / 2,
      0.0,
    );

    // Draw the notch curve
    canvas.drawPath(notchPath, notchPaint);

    // ─── DRAW REST OF THE BORDER ──────────────
    final borderPath = Path();

    // Top right corner
    borderPath.moveTo(size.width - cornerRadius, 0);
    borderPath.arcToPoint(
      Offset(size.width, cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Right side
    borderPath.lineTo(size.width, size.height - cornerRadius);

    // Bottom right corner
    borderPath.arcToPoint(
      Offset(size.width - cornerRadius, size.height),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Bottom side
    borderPath.lineTo(cornerRadius, size.height);

    // Bottom left corner
    borderPath.arcToPoint(
      Offset(0, size.height - cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Left side
    borderPath.lineTo(0, cornerRadius);

    // Top left corner
    borderPath.arcToPoint(
      Offset(cornerRadius, 0),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Draw the rest of the border
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
