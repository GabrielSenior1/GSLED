import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerSheet extends StatelessWidget {
  final String title;
  final Color currentColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerSheet({
    super.key,
    required this.title,
    required this.currentColor,
    required this.onColorChanged,
  });

  static const List<Color> neonPalette = [
    Color(0xFF00FF66), // Matrix Green
    Color(0xFF00FFFF), // Cyan
    Color(0xFFFF007F), // Neon Pink / Magenta
    Color(0xFFFF1744), // Super Red
    Color(0xFFFFD700), // Gold / Amber
    Color(0xFFFF9100), // Neon Orange
    Color(0xFF76FF03), // Lime Green
    Color(0xFF2979FF), // Electric Blue
    Color(0xFFD500F9), // Purple Neon
    Color(0xFFFFFFFF), // Pure White
    Color(0xFF00E676), // Spring Green
    Color(0xFFFF4081), // Coral Pink
    Color(0xFF18FFFF), // Ice Cyan
    Color(0xFFFF5252), // Sunset Red
  ];

  static const List<Color> darkBackgroundPalette = [
    Color(0xFF050505), // Deep Black
    Color(0xFF0A0F1D), // Dark Navy
    Color(0xFF140727), // Deep Violet
    Color(0xFF1A0A0A), // Dark Crimson
    Color(0xFF0D1B1E), // Dark Teal
    Color(0xFF1E1E1E), // Dark Slate
  ];

  @override
  Widget build(BuildContext context) {
    Color pickerColor = currentColor;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F2C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          const Text(
            'Colores Neón Recomendados:',
            style: TextStyle(color: Colors.white70, fontSize: 13.0),
          ),
          const SizedBox(height: 10.0),
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: neonPalette.map((color) {
              final isSelected = color.toARGB32() == currentColor.toARGB32();
              return GestureDetector(
                onTap: () {
                  onColorChanged(color);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.6),
                        blurRadius: 8.0,
                        spreadRadius: 1.0,
                      ),
                    ],
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.black38,
                      width: isSelected ? 3.0 : 1.0,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.black, size: 24.0)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C3246),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            icon: const Icon(Icons.palette),
            label: const Text('Selector de Color Personalizado (RGB/HSV)'),
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1F2C),
                  title: Text(
                    title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: pickerColor,
                      onColorChanged: (c) => pickerColor = c,
                      enableAlpha: false,
                      displayThumbColor: true,
                      paletteType: PaletteType.hsvWithHue,
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FF66),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Seleccionar'),
                      onPressed: () {
                        onColorChanged(pickerColor);
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
