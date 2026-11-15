import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/led_config.dart';
import 'led_matrix_painter.dart';

class LedDisplayWidget extends StatefulWidget {
  final LedBannerConfig config;
  final bool isFullScreen;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final bool isPaused;

  const LedDisplayWidget({
    super.key,
    required this.config,
    this.isFullScreen = false,
    this.onTap,
    this.onDoubleTap,
    this.isPaused = false,
  });

  @override
  State<LedDisplayWidget> createState() => _LedDisplayWidgetState();
}

class _LedDisplayWidgetState extends State<LedDisplayWidget>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  // Marquee position in pixels
  double _scrollOffset = 0.0;
  double _measuredTextWidth = 0.0;
  double _measuredTextHeight = 0.0;

  // Rainbow & Blink phase
  double _rainbowPhase = 0.0;
  int _lastBlinkTimeMs = 0;
  double _blinkOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }

    final double deltaSeconds = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    // 1. Rainbow phase update (smooth continuous cycle)
    if (widget.config.isRainbow) {
      _rainbowPhase = (_rainbowPhase + (deltaSeconds * 0.35)) % 1.0;
    }

    // 2. Blink update
    final blinkPeriod = widget.config.blinkMode.periodMs;
    if (blinkPeriod == 0) {
      _blinkOpacity = 1.0;
    } else {
      final nowMs = elapsed.inMilliseconds;
      if (nowMs - _lastBlinkTimeMs >= (blinkPeriod / 2)) {
        _lastBlinkTimeMs = nowMs;
        if (widget.config.blinkMode == BlinkMode.strobe) {
          _blinkOpacity = _blinkOpacity > 0.5 ? 0.05 : 1.0;
        } else {
          _blinkOpacity = _blinkOpacity > 0.5 ? 0.15 : 1.0;
        }
      }
    }

    // 3. Constant linear speed scroll update
    if (widget.isPaused ||
        widget.config.speed <= 0 ||
        widget.config.direction == ScrollDirection.staticCenter) {
      // Keep static
      setState(() {});
      return;
    }

    // Linear speed in pixels per second:
    // Speed 1 -> 90 px/s, Speed 5 -> 370 px/s, Speed 10 -> 720 px/s
    final double pixelsPerSecond = 20.0 + (widget.config.speed * 70.0);
    _scrollOffset += pixelsPerSecond * deltaSeconds;

    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  /// Calculates the optimal font size so the letters fill the screen vertically
  double _calculateEffectiveFontSize(double availableHeight) {
    if (widget.isFullScreen) {
      // In fullscreen, letters should fill 75% to 85% of available height
      // Size slider adjusts between 55% and 92% of screen height
      final factor = 0.55 + ((widget.config.fontSize / 140.0) * 0.37);
      return (availableHeight * factor).clamp(40.0, availableHeight * 0.92);
    } else {
      // In studio preview card
      return (availableHeight * 0.65).clamp(24.0, 75.0);
    }
  }

  TextStyle _buildTextStyle(double effectiveFontSize) {
    final textColor = widget.config.textColor;
    final glow = widget.config.glowIntensity;

    List<Shadow> shadows = [];
    if (glow > 0) {
      shadows = [
        Shadow(
          color: textColor.withValues(alpha: 0.9),
          blurRadius: 6.0 * glow,
        ),
        Shadow(
          color: textColor.withValues(alpha: 0.6),
          blurRadius: 16.0 * glow,
        ),
        Shadow(
          color: textColor.withValues(alpha: 0.4),
          blurRadius: 32.0 * glow,
        ),
      ];
    }

    switch (widget.config.matrixStyle) {
      case LedMatrixStyle.dotMatrix:
        return GoogleFonts.vt323(
          fontSize: effectiveFontSize,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 2.0,
          height: 1.0,
          shadows: shadows,
        );
      case LedMatrixStyle.squareMatrix:
        return GoogleFonts.silkscreen(
          fontSize: effectiveFontSize * 0.72,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 2.0,
          height: 1.0,
          shadows: shadows,
        );
      case LedMatrixStyle.retroArcade:
        return GoogleFonts.pressStart2p(
          fontSize: effectiveFontSize * 0.60,
          color: textColor,
          letterSpacing: 2.0,
          height: 1.0,
          shadows: shadows,
        );
      case LedMatrixStyle.neonGlow:
        return GoogleFonts.orbitron(
          fontSize: effectiveFontSize * 0.75,
          fontWeight: FontWeight.w900,
          color: textColor,
          letterSpacing: 2.5,
          height: 1.0,
          shadows: [
            ...shadows,
            Shadow(
              color: textColor.withValues(alpha: 0.9),
              blurRadius: 28.0 * glow,
            ),
          ],
        );
    }
  }

  void _measureText(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text.isEmpty ? ' ' : text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    _measuredTextWidth = painter.width;
    _measuredTextHeight = painter.height;
  }

  Widget _buildRenderedText(TextStyle style) {
    Widget textWidget = Text(
      widget.config.text.isEmpty ? ' ' : widget.config.text,
      style: style,
      maxLines: 1,
      softWrap: false,
    );

    if (widget.config.isRainbow) {
      textWidget = ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: const [
              Color(0xFFFF0055), // Hot pink
              Color(0xFFFF7700), // Neon orange
              Color(0xFFFFEE00), // Yellow
              Color(0xFF00FF66), // Lime green
              Color(0xFF00EEFF), // Cyan
              Color(0xFF8800FF), // Violet
              Color(0xFFFF0055), // Loop
            ],
            stops: const [0.0, 0.17, 0.33, 0.5, 0.67, 0.83, 1.0],
            transform: GradientRotation(_rainbowPhase * 2 * math.pi),
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcIn,
        child: textWidget,
      );
    }

    return textWidget;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        final effectiveFontSize = _calculateEffectiveFontSize(screenHeight);
        final textStyle = _buildTextStyle(effectiveFontSize);

        _measureText(widget.config.text, textStyle);

        final textW = _measuredTextWidth > 0 ? _measuredTextWidth : 200.0;
        final textH = _measuredTextHeight > 0 ? _measuredTextHeight : 60.0;

        // Calculate translation offset based on direction & linear scroll offset
        Offset offset = Offset.zero;

        switch (widget.config.direction) {
          case ScrollDirection.rightToLeft:
            final totalDistance = screenWidth + textW + 40.0;
            final currentProgress = _scrollOffset % totalDistance;
            final currentX = screenWidth - currentProgress;
            final centerY = (screenHeight - textH) / 2.0;
            offset = Offset(currentX, centerY);
            break;

          case ScrollDirection.leftToRight:
            final totalDistance = screenWidth + textW + 40.0;
            final currentProgress = _scrollOffset % totalDistance;
            final currentX = -textW + currentProgress;
            final centerY = (screenHeight - textH) / 2.0;
            offset = Offset(currentX, centerY);
            break;

          case ScrollDirection.topToBottom:
            final totalDistance = screenHeight + textH + 40.0;
            final currentProgress = _scrollOffset % totalDistance;
            final currentY = -textH + currentProgress;
            final centerX = (screenWidth - textW) / 2.0;
            offset = Offset(centerX, currentY);
            break;

          case ScrollDirection.bottomToTop:
            final totalDistance = screenHeight + textH + 40.0;
            final currentProgress = _scrollOffset % totalDistance;
            final currentY = screenHeight - currentProgress;
            final centerX = (screenWidth - textW) / 2.0;
            offset = Offset(centerX, currentY);
            break;

          case ScrollDirection.staticCenter:
            offset = Offset(
              (screenWidth - textW) / 2.0,
              (screenHeight - textH) / 2.0,
            );
            break;
        }

        Widget movingText = Transform.translate(
          offset: offset,
          child: _buildRenderedText(textStyle),
        );

        if (widget.config.isMirrored) {
          movingText = Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: movingText,
          );
        }

        return GestureDetector(
          onTap: widget.onTap,
          onDoubleTap: widget.onDoubleTap,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Static physical diode grid (Cached by RepaintBoundary for 120 FPS!)
              RepaintBoundary(
                child: CustomPaint(
                  painter: LedBackgroundBoardPainter(
                    backgroundColor: widget.config.backgroundColor,
                    unlitDotColor: widget.config.unlitDotColor,
                    style: widget.config.matrixStyle,
                    dotPitch: widget.isFullScreen ? 14.0 : 8.0,
                  ),
                ),
              ),

              // 2. Glowing animated marquee text
              Opacity(
                opacity: _blinkOpacity,
                child: movingText,
              ),
            ],
          ),
        );
      },
    );
  }
}
