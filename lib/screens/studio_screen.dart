import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/led_config.dart';
import '../services/storage_service.dart';
import '../widgets/led_display_widget.dart';
import '../widgets/color_picker_sheet.dart';
import '../widgets/preset_selector_chips.dart';
import 'fullscreen_led_screen.dart';

class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key});

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  late TextEditingController _textController;
  LedBannerConfig _config = const LedBannerConfig(
    id: 'current',
    text: '★ LETRERO LED PRO ★',
    speed: 4.5,
    fontSize: 72.0,
  );
  List<LedBannerConfig> _favorites = [];

  static const List<String> _quickEmojis = [
    '❤️', '🔥', '🎉', '🚨', '✈️', '🚖', '🍻', '🎶', '👑', '💯', '⚠️', '⭐', '🎂', '⚡'
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _config.text);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final saved = await StorageService.loadCurrentConfig();
    final favs = await StorageService.loadFavorites();
    if (mounted) {
      setState(() {
        if (saved != null) {
          _config = saved;
          _textController.text = saved.text;
        }
        _favorites = favs;
      });
    }
  }

  void _updateConfig(LedBannerConfig newConfig) {
    setState(() {
      _config = newConfig;
    });
    StorageService.saveCurrentConfig(newConfig);
  }

  void _openFullscreen() async {
    HapticFeedback.mediumImpact();
    final updated = await Navigator.push<LedBannerConfig>(
      context,
      MaterialPageRoute(
        builder: (_) => FullscreenLedScreen(initialConfig: _config),
      ),
    );
    if (updated != null && mounted) {
      _updateConfig(updated);
      _textController.text = updated.text;
    }
  }

  void _saveFavorite() async {
    HapticFeedback.mediumImpact();
    await StorageService.addFavorite(_config);
    final favs = await StorageService.loadFavorites();
    if (mounted) {
      setState(() {
        _favorites = favs;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Guardado en favoritos: "${_config.text}"'),
          backgroundColor: const Color(0xFF00FF66),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openColorPicker({
    required String title,
    required Color currentColor,
    required ValueChanged<Color> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ColorPickerSheet(
        title: title,
        currentColor: currentColor,
        onColorChanged: onSelected,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10141E),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _config.textColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.blur_on, color: _config.textColor, size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'Letrero LED Pro',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined, color: Colors.white70),
            tooltip: 'Guardar como Favorito',
            onPressed: _saveFavorite,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Live Preview Billboard
            _buildLivePreviewCard(),

            // 2. Editor Controls
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                children: [
                  // Text Input Box
                  _buildTextInputSection(),
                  const SizedBox(height: 14),

                  // Quick Emojis Bar
                  _buildEmojiBar(),
                  const SizedBox(height: 16),

                  // Presets and Favorites Carousel
                  _buildSectionTitle('Plantillas y Favoritos'),
                  const SizedBox(height: 8),
                  PresetSelectorChips(
                    presets: _favorites.isNotEmpty ? _favorites : LedBannerConfig.defaultPresets,
                    onSelected: (preset) {
                      _textController.text = preset.text;
                      _updateConfig(preset);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Section: Velocidad & Dirección
                  _buildSectionTitle('Velocidad y Dirección'),
                  const SizedBox(height: 8),
                  _buildSpeedAndDirectionSection(),
                  const SizedBox(height: 20),

                  // Section: Tamaño & Estilo de Matriz
                  _buildSectionTitle('Tamaño y Efecto LED'),
                  const SizedBox(height: 8),
                  _buildSizeAndStyleSection(),
                  const SizedBox(height: 20),

                  // Section: Colores & Resplandor
                  _buildSectionTitle('Colores y Brillo'),
                  const SizedBox(height: 8),
                  _buildColorsSection(),
                  const SizedBox(height: 20),

                  // Section: Efectos Especiales & Orientación
                  _buildSectionTitle('Efectos y Pantalla'),
                  const SizedBox(height: 8),
                  _buildSpecialEffectsSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),

            // 3. Glowing Fullscreen Launch Bar
            _buildStartBannerBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePreviewCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      height: 110.0,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: _config.textColor.withValues(alpha: 0.5),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: _config.textColor.withValues(alpha: 0.25),
            blurRadius: 18.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.0),
        child: Stack(
          children: [
            LedDisplayWidget(
              config: _config,
              isFullScreen: false,
              onTap: _openFullscreen,
            ),
            Positioned(
              top: 6,
              right: 8,
              child: GestureDetector(
                onTap: _openFullscreen,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fullscreen, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('Vista Previa', style: TextStyle(color: Colors.white, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: _config.textColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildTextInputSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151924),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF262E40)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.edit_note, color: Colors.white60),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Escribe tu texto para el letrero...',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
              onChanged: (val) {
                _updateConfig(_config.copyWith(text: val));
              },
            ),
          ),
          if (_textController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white54, size: 20),
              onPressed: () {
                _textController.clear();
                _updateConfig(_config.copyWith(text: ''));
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmojiBar() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _quickEmojis.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final emoji = _quickEmojis[index];
          return GestureDetector(
            onTap: () {
              final newText = _textController.text + emoji;
              _textController.text = newText;
              _updateConfig(_config.copyWith(text: newText));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF191F2D),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2C3449)),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 16)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpeedAndDirectionSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141924),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF242C3E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Speed Slider
          Row(
            children: [
              const Icon(Icons.speed, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              const Text('Velocidad', style: TextStyle(color: Colors.white70)),
              const Spacer(),
              Text(
                _config.speed == 0 ? 'Pausado' : _config.speed.toStringAsFixed(1),
                style: TextStyle(
                  color: _config.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _config.textColor,
              thumbColor: _config.textColor,
              inactiveTrackColor: Colors.white12,
            ),
            child: Slider(
              value: _config.speed,
              min: 0.0,
              max: 10.0,
              divisions: 20,
              onChanged: (val) {
                _updateConfig(_config.copyWith(speed: val));
              },
            ),
          ),

          const SizedBox(height: 10),

          // Direction Chips
          const Text('Dirección de Movimiento', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ScrollDirection.values.map((dir) {
              final isSelected = _config.direction == dir;
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      dir.icon,
                      size: 16,
                      color: isSelected ? Colors.black : Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Text(dir.label),
                  ],
                ),
                selected: isSelected,
                selectedColor: _config.textColor,
                backgroundColor: const Color(0xFF1F2637),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
                onSelected: (_) => _updateConfig(_config.copyWith(direction: dir)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeAndStyleSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141924),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF242C3E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Font Size Slider
          Row(
            children: [
              const Icon(Icons.format_size, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              const Text('Tamaño del Texto', style: TextStyle(color: Colors.white70)),
              const Spacer(),
              Text(
                '${_config.fontSize.toInt()} px',
                style: TextStyle(
                  color: _config.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _config.textColor,
              thumbColor: _config.textColor,
              inactiveTrackColor: Colors.white12,
            ),
            child: Slider(
              value: _config.fontSize,
              min: 36.0,
              max: 140.0,
              divisions: 26,
              onChanged: (val) {
                _updateConfig(_config.copyWith(fontSize: val));
              },
            ),
          ),

          const SizedBox(height: 10),

          // Matrix Style
          const Text('Estilo de Panel LED', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: LedMatrixStyle.values.map((style) {
              final isSelected = _config.matrixStyle == style;
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      style.icon,
                      size: 16,
                      color: isSelected ? Colors.black : Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Text(style.label),
                  ],
                ),
                selected: isSelected,
                selectedColor: _config.textColor,
                backgroundColor: const Color(0xFF1F2637),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
                onSelected: (_) => _updateConfig(_config.copyWith(matrixStyle: style)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141924),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF242C3E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rainbow RGB Mode Switch
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Row(
              children: [
                Icon(Icons.looks, color: Colors.amberAccent, size: 20),
                SizedBox(width: 8),
                Text('Modo Arcoíris RGB Dinámico', style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
            subtitle: const Text(
              'Ciclo animado multicolor en los LEDs',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            value: _config.isRainbow,
            activeColor: const Color(0xFF00FF66),
            onChanged: (val) {
              _updateConfig(_config.copyWith(isRainbow: val));
            },
          ),

          const Divider(color: Colors.white12),

          // Text Color Picker
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _config.textColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _config.textColor.withValues(alpha: 0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            title: const Text('Color del Texto LED', style: TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: const Text('Elige colores neón o personalizados', style: TextStyle(color: Colors.white54, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () {
              _openColorPicker(
                title: 'Color del Texto LED',
                currentColor: _config.textColor,
                onSelected: (c) => _updateConfig(_config.copyWith(textColor: c)),
              );
            },
          ),

          const Divider(color: Colors.white12),

          // Background Color Picker
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _config.backgroundColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white30),
              ),
            ),
            title: const Text('Color de Fondo del Tablero', style: TextStyle(color: Colors.white, fontSize: 14)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () {
              _openColorPicker(
                title: 'Color de Fondo',
                currentColor: _config.backgroundColor,
                onSelected: (c) => _updateConfig(_config.copyWith(backgroundColor: c)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialEffectsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141924),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF242C3E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parpadeo / Blink Mode
          const Text('Efecto de Parpadeo', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BlinkMode.values.map((b) {
              final isSelected = _config.blinkMode == b;
              return ChoiceChip(
                label: Text(b.label),
                selected: isSelected,
                selectedColor: _config.textColor,
                backgroundColor: const Color(0xFF1F2637),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
                onSelected: (_) => _updateConfig(_config.copyWith(blinkMode: b)),
              );
            }).toList(),
          ),

          const Divider(color: Colors.white12, height: 24),

          // Mirror Mode
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Row(
              children: [
                Icon(Icons.flip, color: Colors.white70, size: 20),
                SizedBox(width: 8),
                Text('Modo Espejo (Retrovisor)', style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
            subtitle: const Text(
              'Invierte el texto para leerse en espejos de carros',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            value: _config.isMirrored,
            activeColor: _config.textColor,
            onChanged: (val) {
              _updateConfig(_config.copyWith(isMirrored: val));
            },
          ),

          const Divider(color: Colors.white12, height: 24),

          // Screen Orientation
          const Text('Orientación de Pantalla Completa', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ScreenOrientationMode.values.map((orient) {
              final isSelected = _config.orientationMode == orient;
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      orient.icon,
                      size: 16,
                      color: isSelected ? Colors.black : Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Text(orient.label),
                  ],
                ),
                selected: isSelected,
                selectedColor: _config.textColor,
                backgroundColor: const Color(0xFF1F2637),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
                onSelected: (_) => _updateConfig(_config.copyWith(orientationMode: orient)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStartBannerBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Color(0xFF10141E),
        border: Border(top: BorderSide(color: Color(0xFF202738))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54.0,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: _config.textColor,
            foregroundColor: Colors.black,
            elevation: 8,
            shadowColor: _config.textColor.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          icon: const Icon(Icons.play_circle_fill, size: 26),
          label: const Text(
            'INICIAR LETRERO EN PANTALLA COMPLETA',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          onPressed: _openFullscreen,
        ),
      ),
    );
  }
}
