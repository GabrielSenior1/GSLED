import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/led_config.dart';
import '../widgets/led_display_widget.dart';

class FullscreenLedScreen extends StatefulWidget {
  final LedBannerConfig initialConfig;

  const FullscreenLedScreen({
    super.key,
    required this.initialConfig,
  });

  @override
  State<FullscreenLedScreen> createState() => _FullscreenLedScreenState();
}

class _FullscreenLedScreenState extends State<FullscreenLedScreen> {
  late LedBannerConfig _config;
  bool _showHud = false;
  bool _isPaused = false;
  Timer? _hudTimer;

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig;

    _setupEnvironment();

    // Show HUD briefly for 2.5 seconds on start so user knows how to interact
    _showHud = true;
    _startHudTimeout();
  }

  void _setupEnvironment() {
    // 1. Keep display awake
    try {
      WakelockPlus.enable();
    } catch (_) {}

    // 2. Immersive full screen mode (hide top notch, status bar, and navigation bar)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // 3. Set orientation according to configuration
    switch (_config.orientationMode) {
      case ScreenOrientationMode.landscape:
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        break;
      case ScreenOrientationMode.portrait:
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        break;
      case ScreenOrientationMode.auto:
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        break;
    }
  }

  void _restoreEnvironment() {
    try {
      WakelockPlus.disable();
    } catch (_) {}
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _toggleHud() {
    setState(() {
      _showHud = !_showHud;
    });
    if (_showHud) {
      _startHudTimeout();
    } else {
      _hudTimer?.cancel();
    }
  }

  void _startHudTimeout() {
    _hudTimer?.cancel();
    _hudTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showHud = false;
        });
      }
    });
  }

  void _exit() {
    _restoreEnvironment();
    Navigator.pop(context, _config);
  }

  @override
  void dispose() {
    _hudTimer?.cancel();
    _restoreEnvironment();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _restoreEnvironment();
        }
      },
      child: Scaffold(
        backgroundColor: _config.backgroundColor,
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            // Core LED Marquee Display — fills entire screen
            Positioned.fill(
              child: LedDisplayWidget(
                config: _config,
                isFullScreen: true,
                isPaused: _isPaused,
                onTap: _toggleHud,
                onDoubleTap: _exit,
              ),
            ),

            // Top-Right Tip Indicator (subtle, disappears)
            if (_showHud)
              Positioned(
                top: 20,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, color: Colors.white70, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Doble toque para salir',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

            // Floating Controls HUD
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              bottom: _showHud ? 20 : -140,
              left: 20,
              right: 20,
              child: IgnorePointer(
                ignoring: !_showHud,
                child: AnimatedOpacity(
                  opacity: _showHud ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: _buildControlsHud(),
                ),
              ),
            ),

            // Top Exit Button
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              top: _showHud ? 20 : -80,
              left: 20,
              child: IgnorePointer(
                ignoring: !_showHud,
                child: AnimatedOpacity(
                  opacity: _showHud ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: FloatingActionButton.small(
                    heroTag: 'exit_btn',
                    backgroundColor: Colors.black.withValues(alpha: 0.75),
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(side: BorderSide(color: Colors.white30)),
                    onPressed: _exit,
                    child: const Icon(Icons.arrow_back),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsHud() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF141824).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: _config.textColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 16.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Quick Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Play/Pause
              IconButton(
                icon: Icon(
                  _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _isPaused = !_isPaused;
                  });
                  _startHudTimeout();
                },
                tooltip: _isPaused ? 'Reanudar' : 'Pausar',
              ),

              // Mirror Toggle
              IconButton(
                icon: Icon(
                  Icons.flip,
                  color: _config.isMirrored ? _config.textColor : Colors.white70,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _config = _config.copyWith(isMirrored: !_config.isMirrored);
                  });
                  _startHudTimeout();
                },
                tooltip: 'Modo Espejo (Retrovisor)',
              ),

              // Blink Cycle
              IconButton(
                icon: Icon(
                  Icons.flash_on,
                  color: _config.blinkMode != BlinkMode.off
                      ? _config.textColor
                      : Colors.white70,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  final nextIndex = (_config.blinkMode.index + 1) % BlinkMode.values.length;
                  setState(() {
                    _config = _config.copyWith(blinkMode: BlinkMode.values[nextIndex]);
                  });
                  _startHudTimeout();
                },
                tooltip: 'Parpadeo (${_config.blinkMode.label})',
              ),

              // Rainbow Cycle
              IconButton(
                icon: Icon(
                  Icons.looks,
                  color: _config.isRainbow ? Colors.amberAccent : Colors.white70,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _config = _config.copyWith(isRainbow: !_config.isRainbow);
                  });
                  _startHudTimeout();
                },
                tooltip: 'Modo Arcoíris',
              ),

              // Direction Cycle
              IconButton(
                icon: Icon(_config.direction.icon, color: Colors.white),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  final nextIndex =
                      (_config.direction.index + 1) % ScrollDirection.values.length;
                  setState(() {
                    _config = _config.copyWith(direction: ScrollDirection.values[nextIndex]);
                  });
                  _startHudTimeout();
                },
                tooltip: 'Dirección: ${_config.direction.label}',
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Row 2: Live Speed Slider
          Row(
            children: [
              const Icon(Icons.speed, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _config.textColor,
                    thumbColor: _config.textColor,
                    inactiveTrackColor: Colors.white24,
                    trackHeight: 3.5,
                  ),
                  child: Slider(
                    value: _config.speed,
                    min: 0.0,
                    max: 10.0,
                    divisions: 20,
                    label: _config.speed.toStringAsFixed(1),
                    onChanged: (val) {
                      setState(() {
                        _config = _config.copyWith(speed: val);
                      });
                      _startHudTimeout();
                    },
                  ),
                ),
              ),
              Text(
                'Vel: ${_config.speed.toStringAsFixed(1)}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
