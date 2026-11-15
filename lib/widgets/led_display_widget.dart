import 'dart:math' as math;
import 'package:flutter/material.dart';
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
    with TickerProviderStateMixin {
  late AnimationController _scrollController;
  late AnimationController _blinkController;
  late AnimationController _rainbowController;

  double _textWidth = 0.0;
  double _textHeight = 0.0;
  final GlobalKey _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _scrollController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _rainbowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _updateControllers();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureText();
    });
  }

  @override
  void didUpdateWidget(covariant LedDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.speed != widget.config.speed ||
        oldWidget.config.direction != widget.config.direction ||
        oldWidget.config.text != widget.config.text ||
        oldWidget.config.fontSize != widget.config.fontSize ||
        oldWidget.config.blinkMode != widget.config.blinkMode ||
        oldWidget.isPaused != widget.isPaused) {
      _updateControllers();
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureText());
    }
  }

  void _updateControllers() {
    // 1. Blink Controller
    final period = widget.config.blinkMode.periodMs;
    if (period == 0) {
      _blinkController.stop();
      _blinkController.value = 1.0;
    } else {
      _blinkController.duration = Duration(milliseconds: period);
      if (!_blinkController.isAnimating) {
        _blinkController.repeat(reverse: true);
      }
    }

    // 2. Scroll Controller
    if (widget.isPaused || widget.config.speed <= 0 ||
        widget.config.direction == ScrollDirection.staticCenter) {
      if (_scrollController.isAnimating) {
        _scrollController.stop();
      }
    } else {
      // Calculate duration inversely proportional to speed:
      // speed 1 => slow (24s for standard screen length)
      // speed 10 => fast (2.5s)
      final durationSeconds = math.max(1.5, (11.0 - widget.config.speed) * 2.2);
      _scrollController.duration = Duration(
        milliseconds: (durationSeconds * 1000).toInt(),
      );
      if (!_scrollController.isAnimating) {
        _scrollController.repeat();
      }
    }
  }

  void _measureText() {
    final context = _textKey.currentContext;
    if (context != null) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        setState(() {
          _textWidth = renderBox.size.width;
          _textHeight = renderBox.size.height;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _blinkController.dispose();
    _rainbowController.dispose();
    super.dispose();
  }

  TextStyle _getLedTextStyle() {
    final textColor = widget.config.textColor;
    final glow = widget.config.glowIntensity;

    List<Shadow> shadows = [];
    if (glow > 0) {
      shadows = [
        Shadow(
          color: textColor.withValues(alpha: 0.9),
          blurRadius: 4.0 * glow,
        ),
        Shadow(
          color: textColor.withValues(alpha: 0.7),
          blurRadius: 12.0 * glow,
        ),
        Shadow(
          color: textColor.withValues(alpha: 0.5),
          blurRadius: 28.0 * glow,
        ),
      ];
    }

    // Font styling based on Matrix style
    switch (widget.config.matrixStyle) {
      case LedMatrixStyle.dotMatrix:
        return GoogleFonts.vt323(
          fontSize: widget.config.fontSize,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 3.0,
          shadows: shadows,
        );
      case LedMatrixStyle.squareMatrix:
        return GoogleFonts.silkscreen(
          fontSize: widget.config.fontSize * 0.75,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 2.0,
          shadows: shadows,
        );
      case LedMatrixStyle.retroArcade:
        return GoogleFonts.pressStart2p(
          fontSize: widget.config.fontSize * 0.65,
          color: textColor,
          letterSpacing: 2.0,
          shadows: shadows,
        );
      case LedMatrixStyle.neonGlow:
        return GoogleFonts.orbitron(
          fontSize: widget.config.fontSize * 0.85,
          fontWeight: FontWeight.w900,
          color: textColor,
          letterSpacing: 2.5,
          shadows: [
            ...shadows,
            Shadow(
              color: textColor.withValues(alpha: 0.9),
              blurRadius: 36.0 * glow,
            ),
          ],
        );
    }
  }

  Widget _buildGlowingText() {
    final style = _getLedTextStyle();

    Widget textWidget = Text(
      widget.config.text.isEmpty ? ' ' : widget.config.text,
      key: _textKey,
      style: style,
      maxLines: 1,
      softWrap: false,
    );

    // Apply Rainbow Shader if enabled
    if (widget.config.isRainbow) {
      textWidget = AnimatedBuilder(
        animation: _rainbowController,
        builder: (context, child) {
          final phase = _rainbowController.value;
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: const [
                  Color(0xFFFF0055), // Hot pink
                  Color(0xFFFF7700), // Neon orange
                  Color(0xFFFFEE00), // Bright yellow
                  Color(0xFF00FF66), // Lime neon
                  Color(0xFF00EEFF), // Cyan
                  Color(0xFF8800FF), // Violet
                  Color(0xFFFF0055), // Loop back
                ],
                stops: const [0.0, 0.17, 0.33, 0.5, 0.67, 0.83, 1.0],
                transform: GradientRotation(phase * 2 * math.pi),
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: child,
          );
        },
        child: textWidget,
      );
    }

    return textWidget;
  }

  @override
  Widget build(BuildContext context) {
    // Determine dot pitch based on screen and font size
    final dotPitch = widget.isFullScreen ? 12.0 : 8.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        return GestureDetector(
          onTap: widget.onTap,
          onDoubleTap: widget.onDoubleTap,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Background Board with unlit diodes
              CustomPaint(
                painter: LedBackgroundBoardPainter(
                  backgroundColor: widget.config.backgroundColor,
                  unlitDotColor: widget.config.unlitDotColor,
                  style: widget.config.matrixStyle,
                  dotPitch: dotPitch,
                ),
              ),

              // 2. Animated Scrolling Text
              AnimatedBuilder(
                animation: Listenable.merge([
                  _scrollController,
                  _blinkController,
                ]),
                builder: (context, child) {
                  // Calculate Blink Opacity
                  double opacity = 1.0;
                  if (widget.config.blinkMode != BlinkMode.off) {
                    // Strobe is sharp square wave, others are smooth
                    if (widget.config.blinkMode == BlinkMode.strobe) {
                      opacity = _blinkController.value > 0.5 ? 1.0 : 0.05;
                    } else {
                      opacity = 0.15 + (0.85 * _blinkController.value);
                    }
                  }

                  // Calculate Marquee Translation
                  Offset offset = Offset.zero;
                  final textW = _textWidth > 0 ? _textWidth : 300.0;
                  final textH = _textHeight > 0 ? _textHeight : 60.0;
                  final progress = _scrollController.value;

                  switch (widget.config.direction) {
                    case ScrollDirection.rightToLeft:
                      final totalDistance = screenWidth + textW;
                      final currentX = screenWidth - (progress * totalDistance);
                      final centerY = (screenHeight - textH) / 2;
                      offset = Offset(currentX, centerY);
                      break;

                    case ScrollDirection.leftToRight:
                      final totalDistance = screenWidth + textW;
                      final currentX = -textW + (progress * totalDistance);
                      final centerY = (screenHeight - textH) / 2;
                      offset = Offset(currentX, centerY);
                      break;

                    case ScrollDirection.topToBottom:
                      final totalDistance = screenHeight + textH;
                      final currentY = -textH + (progress * totalDistance);
                      final centerX = (screenWidth - textW) / 2;
                      offset = Offset(centerX, currentY);
                      break;

                    case ScrollDirection.bottomToTop:
                      final totalDistance = screenHeight + textH;
                      final currentY = screenHeight - (progress * totalDistance);
                      final centerX = (screenWidth - textW) / 2;
                      offset = Offset(centerX, currentY);
                      break;

                    case ScrollDirection.staticCenter:
                      offset = Offset(
                        (screenWidth - textW) / 2,
                        (screenHeight - textH) / 2,
                      );
                      break;
                  }

                  Widget movingContent = Transform.translate(
                    offset: offset,
                    child: _buildGlowingText(),
                  );

                  // Mirror mode for car rear-view mirror
                  if (widget.config.isMirrored) {
                    movingContent = Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: movingContent,
                    );
                  }

                  return Opacity(
                    opacity: opacity,
                    child: movingContent,
                  );
                },
              ),

              // 3. Perforated Mask Layer (creates authentic circular/square LED diode holes)
              if (widget.config.matrixStyle != LedMatrixStyle.neonGlow)
                IgnorePointer(
                  child: CustomPaint(
                    painter: LedPerforatedMaskPainter(
                      boardColor: widget.config.backgroundColor,
                      style: widget.config.matrixStyle,
                      dotPitch: dotPitch,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
