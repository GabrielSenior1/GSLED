import 'package:flutter/material.dart';
import '../models/led_config.dart';

/// Painter for the physical background LED board with unlit diodes.
class LedBackgroundBoardPainter extends CustomPainter {
  final Color backgroundColor;
  final Color unlitDotColor;
  final LedMatrixStyle style;
  final double dotPitch; // Space between dot centers

  LedBackgroundBoardPainter({
    required this.backgroundColor,
    required this.unlitDotColor,
    required this.style,
    this.dotPitch = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Fill base dark board background
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    if (style == LedMatrixStyle.neonGlow) {
      // For pure neon glow, subtle carbon fiber or fine lines
      final linePaint = Paint()
        ..color = unlitDotColor.withValues(alpha: 0.15)
        ..strokeWidth = 0.5;
      for (double y = 0; y < size.height; y += dotPitch * 1.5) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      }
      return;
    }

    // 2. Draw unlit physical diodes across the board
    final dotRadius = dotPitch * 0.38;
    final dotPaint = Paint()
      ..color = unlitDotColor
      ..style = PaintingStyle.fill;

    final rimPaint = Paint()
      ..color = unlitDotColor.withValues(alpha: 0.4)
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
            width: dotRadius * 2,
            height: dotRadius * 2,
          );
          final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2.0));
          canvas.drawRRect(rrect, dotPaint);
          canvas.drawRRect(rrect, rimPaint);
        } else if (style == LedMatrixStyle.retroArcade) {
          final rect = Rect.fromCenter(
            center: Offset(x, y),
            width: dotRadius * 1.8,
            height: dotRadius * 2.2,
          );
          canvas.drawRect(rect, dotPaint);
        } else {
          // Circular dot matrix
          canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
          canvas.drawCircle(Offset(x, y), dotRadius, rimPaint);
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

/// Overlay painter that punches the text through the LED diode mask grid,
/// giving any text, font, or emoji the authentic physical LED matrix diode appearance!
class LedPerforatedMaskPainter extends CustomPainter {
  final Color boardColor;
  final LedMatrixStyle style;
  final double dotPitch;

  LedPerforatedMaskPainter({
    required this.boardColor,
    required this.style,
    this.dotPitch = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (style == LedMatrixStyle.neonGlow) {
      return; // No mask needed for smooth neon glow
    }

    final maskPaint = Paint()
      ..color = boardColor.withValues(alpha: 0.92)
      ..style = PaintingStyle.fill;

    // Create a path covering the whole canvas, then cut out the diode circles/squares
    final Path maskPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final dotRadius = dotPitch * 0.38;

    final int cols = (size.width / dotPitch).ceil() + 1;
    final int rows = (size.height / dotPitch).ceil() + 1;

    for (int r = 0; r < rows; r++) {
      final y = r * dotPitch + (dotPitch / 2);
      for (int c = 0; c < cols; c++) {
        final x = c * dotPitch + (dotPitch / 2);

        if (style == LedMatrixStyle.squareMatrix) {
          final rect = Rect.fromCenter(
            center: Offset(x, y),
            width: dotRadius * 2,
            height: dotRadius * 2,
          );
          maskPath.addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2.0)));
        } else if (style == LedMatrixStyle.retroArcade) {
          final rect = Rect.fromCenter(
            center: Offset(x, y),
            width: dotRadius * 1.8,
            height: dotRadius * 2.2,
          );
          maskPath.addRect(rect);
        } else {
          // Circular diode
          maskPath.addOval(Rect.fromCircle(center: Offset(x, y), radius: dotRadius));
        }
      }
    }

    maskPath.fillType = PathFillType.evenOdd;
    canvas.drawPath(maskPath, maskPaint);
  }

  @override
  bool shouldRepaint(covariant LedPerforatedMaskPainter oldDelegate) {
    return oldDelegate.boardColor != boardColor ||
        oldDelegate.style != style ||
        oldDelegate.dotPitch != dotPitch;
  }
}
