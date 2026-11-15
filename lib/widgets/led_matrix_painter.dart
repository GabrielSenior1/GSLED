import 'package:flutter/material.dart';
import '../models/led_config.dart';

/// Highly optimized static background painter for the physical LED billboard.
/// Renders an authentic diode matrix without any tessellation cracks or streaks.
class LedBackgroundBoardPainter extends CustomPainter {
  final Color backgroundColor;
  final Color unlitDotColor;
  final LedMatrixStyle style;
  final double dotPitch;

  LedBackgroundBoardPainter({
    required this.backgroundColor,
    required this.unlitDotColor,
    required this.style,
    this.dotPitch = 14.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dark matte base plate
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    if (style == LedMatrixStyle.neonGlow) {
      // Pure clean dark background for neon glow (no lines or streaks)
      return;
    }

    final dotRadius = dotPitch * 0.36;

    final dotPaint = Paint()
      ..color = unlitDotColor
      ..style = PaintingStyle.fill;

    final ringPaint = Paint()
      ..color = unlitDotColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final int cols = (size.width / dotPitch).ceil() + 1;
    final int rows = (size.height / dotPitch).ceil() + 1;

    for (int r = 0; r < rows; r++) {
      final y = r * dotPitch + (dotPitch / 2);
      for (int c = 0; c < cols; c++) {
        final x = c * dotPitch + (dotPitch / 2);

        if (style == LedMatrixStyle.squareMatrix) {
          final rect = Rect.fromCenter(
            center: Offset(x, y),
            width: dotRadius * 2.0,
            height: dotRadius * 2.0,
          );
          final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2.0));
          canvas.drawRRect(rrect, dotPaint);
          canvas.drawRRect(rrect, ringPaint);
        } else if (style == LedMatrixStyle.retroArcade) {
          final rect = Rect.fromCenter(
            center: Offset(x, y),
            width: dotRadius * 1.8,
            height: dotRadius * 2.0,
          );
          canvas.drawRect(rect, dotPaint);
        } else {
          // Authentic circular LED diode with outer bezel
          canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
          canvas.drawCircle(Offset(x, y), dotRadius, ringPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant LedBackgroundBoardPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.unlitDotColor != unlitDotColor ||
        oldDelegate.style != style ||
        oldDelegate.dotPitch != dotPitch;
  }
}
