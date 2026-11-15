import 'package:flutter/material.dart';
import '../models/led_config.dart';

class PresetSelectorChips extends StatelessWidget {
  final List<LedBannerConfig> presets;
  final ValueChanged<LedBannerConfig> onSelected;

  const PresetSelectorChips({
    super.key,
    required this.presets,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: presets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8.0),
        itemBuilder: (context, index) {
          final preset = presets[index];
          return ActionChip(
            backgroundColor: const Color(0xFF1F2433),
            side: BorderSide(
              color: preset.textColor.withValues(alpha: 0.6),
              width: 1.2,
            ),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: preset.textColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: preset.textColor.withValues(alpha: 0.8),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  preset.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            onPressed: () => onSelected(preset),
          );
        },
      ),
    );
  }
}
