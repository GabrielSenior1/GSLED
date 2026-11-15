import 'dart:convert';
import 'package:flutter/material.dart';

enum ScrollDirection {
  rightToLeft,
  leftToRight,
  topToBottom,
  bottomToTop,
  staticCenter,
}

extension ScrollDirectionExt on ScrollDirection {
  String get label {
    switch (this) {
      case ScrollDirection.rightToLeft:
        return 'Derecha a Izq.';
      case ScrollDirection.leftToRight:
        return 'Izq. a Derecha';
      case ScrollDirection.topToBottom:
        return 'Arriba a Abajo';
      case ScrollDirection.bottomToTop:
        return 'Abajo a Arriba';
      case ScrollDirection.staticCenter:
        return 'Fijo / Centrado';
    }
  }

  IconData get icon {
    switch (this) {
      case ScrollDirection.rightToLeft:
        return Icons.arrow_back;
      case ScrollDirection.leftToRight:
        return Icons.arrow_forward;
      case ScrollDirection.topToBottom:
        return Icons.arrow_downward;
      case ScrollDirection.bottomToTop:
        return Icons.arrow_upward;
      case ScrollDirection.staticCenter:
        return Icons.center_focus_strong;
    }
  }
}

enum LedMatrixStyle {
  dotMatrix,
  squareMatrix,
  neonGlow,
  retroArcade,
}

extension LedMatrixStyleExt on LedMatrixStyle {
  String get label {
    switch (this) {
      case LedMatrixStyle.dotMatrix:
        return 'Puntos LED';
      case LedMatrixStyle.squareMatrix:
        return 'Matriz SMD';
      case LedMatrixStyle.neonGlow:
        return 'Neón Puro';
      case LedMatrixStyle.retroArcade:
        return 'Arcade 8-Bit';
    }
  }

  IconData get icon {
    switch (this) {
      case LedMatrixStyle.dotMatrix:
        return Icons.blur_on;
      case LedMatrixStyle.squareMatrix:
        return Icons.grid_view_rounded;
      case LedMatrixStyle.neonGlow:
        return Icons.wb_incandescent_outlined;
      case LedMatrixStyle.retroArcade:
        return Icons.videogame_asset_outlined;
    }
  }
}

enum BlinkMode {
  off,
  slow,
  normal,
  fast,
  strobe,
}

extension BlinkModeExt on BlinkMode {
  String get label {
    switch (this) {
      case BlinkMode.off:
        return 'No';
      case BlinkMode.slow:
        return 'Lento';
      case BlinkMode.normal:
        return 'Medio';
      case BlinkMode.fast:
        return 'Rápido';
      case BlinkMode.strobe:
        return 'Flash!';
    }
  }

  int get periodMs {
    switch (this) {
      case BlinkMode.off:
        return 0;
      case BlinkMode.slow:
        return 1200;
      case BlinkMode.normal:
        return 650;
      case BlinkMode.fast:
        return 350;
      case BlinkMode.strobe:
        return 140;
    }
  }
}

enum ScreenOrientationMode {
  landscape,
  portrait,
  auto,
}

extension ScreenOrientationModeExt on ScreenOrientationMode {
  String get label {
    switch (this) {
      case ScreenOrientationMode.landscape:
        return 'Horizontal (Recomendado)';
      case ScreenOrientationMode.portrait:
        return 'Vertical';
      case ScreenOrientationMode.auto:
        return 'Automático';
    }
  }

  IconData get icon {
    switch (this) {
      case ScreenOrientationMode.landscape:
        return Icons.stay_current_landscape;
      case ScreenOrientationMode.portrait:
        return Icons.stay_current_portrait;
      case ScreenOrientationMode.auto:
        return Icons.screen_rotation;
    }
  }
}

class LedBannerConfig {
  final String id;
  final String name;
  final String text;
  final double fontSize;
  final double speed; // 0.0 (stop) to 10.0 (ultra fast)
  final Color textColor;
  final Color backgroundColor;
  final Color unlitDotColor;
  final ScrollDirection direction;
  final LedMatrixStyle matrixStyle;
  final BlinkMode blinkMode;
  final bool isRainbow;
  final bool isMirrored;
  final double glowIntensity; // 0.0 to 1.0
  final ScreenOrientationMode orientationMode;
  final String fontName;

  const LedBannerConfig({
    required this.id,
    this.name = 'Personalizado',
    required this.text,
    this.fontSize = 72.0,
    this.speed = 4.0,
    this.textColor = const Color(0xFF00FF66), // Classic Matrix green
    this.backgroundColor = const Color(0xFF050505),
    this.unlitDotColor = const Color(0xFF141920),
    this.direction = ScrollDirection.rightToLeft,
    this.matrixStyle = LedMatrixStyle.dotMatrix,
    this.blinkMode = BlinkMode.off,
    this.isRainbow = false,
    this.isMirrored = false,
    this.glowIntensity = 0.8,
    this.orientationMode = ScreenOrientationMode.landscape,
    this.fontName = 'VT323',
  });

  LedBannerConfig copyWith({
    String? id,
    String? name,
    String? text,
    double? fontSize,
    double? speed,
    Color? textColor,
    Color? backgroundColor,
    Color? unlitDotColor,
    ScrollDirection? direction,
    LedMatrixStyle? matrixStyle,
    BlinkMode? blinkMode,
    bool? isRainbow,
    bool? isMirrored,
    double? glowIntensity,
    ScreenOrientationMode? orientationMode,
    String? fontName,
  }) {
    return LedBannerConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      text: text ?? this.text,
      fontSize: fontSize ?? this.fontSize,
      speed: speed ?? this.speed,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      unlitDotColor: unlitDotColor ?? this.unlitDotColor,
      direction: direction ?? this.direction,
      matrixStyle: matrixStyle ?? this.matrixStyle,
      blinkMode: blinkMode ?? this.blinkMode,
      isRainbow: isRainbow ?? this.isRainbow,
      isMirrored: isMirrored ?? this.isMirrored,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      orientationMode: orientationMode ?? this.orientationMode,
      fontName: fontName ?? this.fontName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'text': text,
      'fontSize': fontSize,
      'speed': speed,
      'textColor': textColor.toARGB32(),
      'backgroundColor': backgroundColor.toARGB32(),
      'unlitDotColor': unlitDotColor.toARGB32(),
      'direction': direction.index,
      'matrixStyle': matrixStyle.index,
      'blinkMode': blinkMode.index,
      'isRainbow': isRainbow,
      'isMirrored': isMirrored,
      'glowIntensity': glowIntensity,
      'orientationMode': orientationMode.index,
      'fontName': fontName,
    };
  }

  factory LedBannerConfig.fromMap(Map<String, dynamic> map) {
    return LedBannerConfig(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['name'] ?? 'Guardado',
      text: map['text'] ?? 'LETRERO LED',
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 72.0,
      speed: (map['speed'] as num?)?.toDouble() ?? 4.0,
      textColor: Color(map['textColor'] ?? 0xFF00FF66),
      backgroundColor: Color(map['backgroundColor'] ?? 0xFF050505),
      unlitDotColor: Color(map['unlitDotColor'] ?? 0xFF141920),
      direction: ScrollDirection.values[(map['direction'] as int?) ?? 0],
      matrixStyle: LedMatrixStyle.values[(map['matrixStyle'] as int?) ?? 0],
      blinkMode: BlinkMode.values[(map['blinkMode'] as int?) ?? 0],
      isRainbow: map['isRainbow'] ?? false,
      isMirrored: map['isMirrored'] ?? false,
      glowIntensity: (map['glowIntensity'] as num?)?.toDouble() ?? 0.8,
      orientationMode: ScreenOrientationMode.values[(map['orientationMode'] as int?) ?? 0],
      fontName: map['fontName'] ?? 'VT323',
    );
  }

  String toJson() => json.encode(toMap());

  factory LedBannerConfig.fromJson(String source) =>
      LedBannerConfig.fromMap(json.decode(source));

  static List<LedBannerConfig> get defaultPresets => [
    const LedBannerConfig(
      id: 'p1',
      name: 'Concierto 🎸',
      text: '★ I LOVE ROCK & ROLL ★',
      textColor: Color(0xFFFF007F), // Neon Pink
      isRainbow: true,
      speed: 5.0,
      fontSize: 80.0,
      glowIntensity: 1.0,
      matrixStyle: LedMatrixStyle.dotMatrix,
    ),
    const LedBannerConfig(
      id: 'p2',
      name: 'Taxi 🚕',
      text: '🚖 LIBRE / TAXI DISPONIBLE',
      textColor: Color(0xFFFFD700), // Amber Gold
      speed: 4.0,
      fontSize: 74.0,
      matrixStyle: LedMatrixStyle.squareMatrix,
    ),
    const LedBannerConfig(
      id: 'p3',
      name: 'Aeropuerto ✈️',
      text: 'BIENVENIDO JUAN PÉREZ 🧳',
      textColor: Color(0xFF00E5FF), // Cyan Neon
      speed: 3.5,
      fontSize: 78.0,
      matrixStyle: LedMatrixStyle.dotMatrix,
    ),
    const LedBannerConfig(
      id: 'p4',
      name: 'Cumpleaños 🎂',
      text: '🎉 ¡FELIZ CUMPLEAÑOS! 🎂🎈',
      textColor: Color(0xFFFF9100),
      isRainbow: true,
      speed: 5.0,
      fontSize: 82.0,
      blinkMode: BlinkMode.slow,
    ),
    const LedBannerConfig(
      id: 'p5',
      name: 'Oferta 🔥',
      text: '🔥 50% DESCUENTO HOY 🔥',
      textColor: Color(0xFFFF1744), // Super Red
      speed: 6.0,
      fontSize: 80.0,
      blinkMode: BlinkMode.normal,
      glowIntensity: 1.0,
    ),
    const LedBannerConfig(
      id: 'p6',
      name: 'SOS 🚨',
      text: '🚨 ATENCIÓN / AYUDA 🚨',
      textColor: Color(0xFFFF0000),
      speed: 0.0,
      direction: ScrollDirection.staticCenter,
      blinkMode: BlinkMode.strobe,
      fontSize: 85.0,
      glowIntensity: 1.0,
    ),
  ];
}
