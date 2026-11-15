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

  // Rainbow & Blink phase
  double _rainbowPhase = 0.0;
  int _lastBlinkToggleMs = 0;
  double _blinkOpacity = 1.0;

  // Cached text measurement to avoid re-measuring every frame
  double _cachedTextWidth = 0.0;
  double _cachedTextHeight = 0.0;
  String _lastMeasuredText = '';
  double _lastMeasuredFontSize = 0.0;
  LedMatrixStyle _lastMeasuredStyle = LedMatrixStyle.dotMatrix;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void didUpdateWidget(covariant LedDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset scroll offset when text or direction changes so it starts clean
    if (oldWidget.config.text != widget.config.text ||
        oldWidget.config.direction != widget.config.direction) {
      _scrollOffset = 0.0;
    }
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }

    final double deltaSeconds =
        (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    // Clamp delta to avoid huge jumps after tab switch / resume
    final double dt = deltaSeconds.clamp(0.0, 0.1);

    bool needsRepaint = false;

    // 1. Rainbow phase
    if (widget.config.isRainbow) {
      final oldPhase = _rainbowPhase;
      _rainbowPhase = (_rainbowPhase + (dt * 0.35)) % 1.0;
      if (_rainbowPhase != oldPhase) needsRepaint = true;
    }

    // 2. Blink update
    final blinkPeriod = widget.config.blinkMode.periodMs;
    if (blinkPeriod == 0) {
      if (_blinkOpacity != 1.0) {
        _blinkOpacity = 1.0;
        needsRepaint = true;
      }
    } else {
      final nowMs = elapsed.inMilliseconds;
      if (nowMs - _lastBlinkToggleMs >= (blinkPeriod ~/ 2)) {
        _lastBlinkToggleMs = nowMs;
        final newOpacity = _blinkOpacity > 0.5
            ? (widget.config.blinkMode == BlinkMode.strobe ? 0.05 : 0.15)
            : 1.0;
        if (_blinkOpacity != newOpacity) {
          _blinkOpacity = newOpacity;
          needsRepaint = true;
        }
      }
    }

    // 3. Scroll update
    final bool isScrolling = !widget.isPaused &&
        widget.config.speed > 0 &&
        widget.config.direction != ScrollDirection.staticCenter;

    if (isScrolling) {
      // Linear speed: Speed 1 → 80 px/s, Speed 5 → 360 px/s, Speed 10 → 720 px/s
      final double pixelsPerSecond = 10.0 + (widget.config.speed * 71.0);
      _scrollOffset += pixelsPerSecond * dt;
      needsRepaint = true;
    }

    if (needsRepaint) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  /// Font size calculation that respects the user slider in BOTH modes
  double _calculateEffectiveFontSize(double availableHeight) {
    final double userSize = widget.config.fontSize; // 36..140

    if (widget.isFullScreen) {
      // In fullscreen: map slider 36..140 to 40%..90% of screen height
      final double t = ((userSize - 36.0) / 104.0).clamp(0.0, 1.0);
      final double fraction = 0.40 + (t * 0.50);
      return (availableHeight * fraction).clamp(30.0, availableHeight * 0.92);
    } else {
      // Preview: scale proportionally. Preview ~110px tall.
      // Map slider 36..140 to 35%..80% of available height
      final double t = ((userSize - 36.0) / 104.0).clamp(0.0, 1.0);
      final double fraction = 0.35 + (t * 0.45);
      return (availableHeight * fraction).clamp(14.0, availableHeight * 0.85);
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
          fontSize: effectiveFontSize * 0.55,
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

  void _measureText(String text, TextStyle style, double effectiveFontSize) {
    // Only re-measure when something changed
    if (text == _lastMeasuredText &&
        effectiveFontSize == _lastMeasuredFontSize &&
        widget.config.matrixStyle == _lastMeasuredStyle &&
        _cachedTextWidth > 0) {
      return;
    }

    final painter = TextPainter(
      text: TextSpan(text: text.isEmpty ? ' ' : text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    _cachedTextWidth = painter.width;
    _cachedTextHeight = painter.height;
    _lastMeasuredText = text;
    _lastMeasuredFontSize = effectiveFontSize;
    _lastMeasuredStyle = widget.config.matrixStyle;
  }

  Widget _buildRenderedText(TextStyle style) {
    Widget textWidget = Text(
      widget.config.text.isEmpty ? ' ' : widget.config.text,
      style: style,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.visible,
    );

    if (widget.config.isRainbow) {
      textWidget = ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: const [
              Color(0xFFFF0055),
              Color(0xFFFF7700),
              Color(0xFFFFEE00),
              Color(0xFF00FF66),
              Color(0xFF00EEFF),
              Color(0xFF8800FF),
              Color(0xFFFF0055),
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

        _measureText(widget.config.text, textStyle, effectiveFontSize);

        final textW = _cachedTextWidth > 0 ? _cachedTextWidth : 200.0;
        final textH = _cachedTextHeight > 0 ? _cachedTextHeight : 60.0;

        // Calculate translation offset based on direction & linear scroll offset
        Offset offset;

        switch (widget.config.direction) {
          case ScrollDirection.rightToLeft:
            // Text starts fully off-screen right, exits fully off-screen left
            final totalDistance = screenWidth + textW;
            final currentProgress = _scrollOffset % totalDistance;
            final currentX = screenWidth - currentProgress;
            final centerY = (screenHeight - textH) / 2.0;
            offset = Offset(currentX, centerY);
            break;

          case ScrollDirection.leftToRight:
            final totalDistance = screenWidth + textW;
            final currentProgress = _scrollOffset % totalDistance;
            final currentX = -textW + currentProgress;
            final centerY = (screenHeight - textH) / 2.0;
            offset = Offset(currentX, centerY);
            break;

          case ScrollDirection.topToBottom:
            final totalDistance = screenHeight + textH;
            final currentProgress = _scrollOffset % totalDistance;
            final currentY = -textH + currentProgress;
            final centerX = (screenWidth - textW) / 2.0;
            offset = Offset(centerX, currentY);
            break;

          case ScrollDirection.bottomToTop:
            final totalDistance = screenHeight + textH;
            final currentProgress = _scrollOffset % totalDistance;
            final currentY = screenHeight - currentProgress;
            final centerX = (screenWidth - textW) / 2.0;
            offset = Offset(centerX, currentY);
            break;

          case ScrollDirection.staticCenter:
            // For static mode, if text is wider than screen, auto-scale font down
            double fitFontSize = effectiveFontSize;
            double fitTextW = textW;
            double fitTextH = textH;
            if (textW > screenWidth * 0.95 && screenWidth > 0) {
              final scale = (screenWidth * 0.92) / textW;
              fitFontSize = effectiveFontSize * scale;
              final fitStyle = _buildTextStyle(fitFontSize);
              final painter = TextPainter(
                text: TextSpan(
                  text: widget.config.text.isEmpty ? ' ' : widget.config.text,
                  style: fitStyle,
                ),
                textDirection: TextDirection.ltr,
                maxLines: 1,
              )..layout();
              fitTextW = painter.width;
              fitTextH = painter.height;
            }
            offset = Offset(
              (screenWidth - fitTextW) / 2.0,
              (screenHeight - fitTextH) / 2.0,
            );
            // For static, rebuild with fitted style if needed
            if (fitFontSize != effectiveFontSize) {
              final fitStyle = _buildTextStyle(fitFontSize);
              Widget movingText = Transform.translate(
                offset: offset,
                child: _buildRenderedTextWithStyle(fitStyle),
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
                child: ClipRect(
                  child: Stack(
                    clipBehavior: Clip.none,
                    fit: StackFit.expand,
                    children: [
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
                      Opacity(
                        opacity: _blinkOpacity,
                        child: movingText,
                      ),
                    ],
                  ),
                ),
              );
            }
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

        // ClipRect ensures text entering from outside is clipped at widget bounds
        // but Clip.none on Stack allows Transform.translate to position text outside
        // the Stack bounds — the ClipRect then clips at the parent boundary
        return GestureDetector(
          onTap: widget.onTap,
          onDoubleTap: widget.onDoubleTap,
          behavior: HitTestBehavior.opaque,
          child: ClipRect(
            child: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                // 1. Static physical diode grid
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
          ),
        );
      },
    );
  }

  Widget _buildRenderedTextWithStyle(TextStyle style) {
    Widget textWidget = Text(
      widget.config.text.isEmpty ? ' ' : widget.config.text,
      style: style,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.visible,
    );

    if (widget.config.isRainbow) {
      textWidget = ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: const [
              Color(0xFFFF0055),
              Color(0xFFFF7700),
              Color(0xFFFFEE00),
              Color(0xFF00FF66),
              Color(0xFF00EEFF),
              Color(0xFF8800FF),
              Color(0xFFFF0055),
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
}
