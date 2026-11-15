import 'package:shared_preferences/shared_preferences.dart';
import '../models/led_config.dart';

class StorageService {
  static const String _keyLastConfig = 'led_last_config';
  static const String _keyFavorites = 'led_favorites';

  static Future<void> saveCurrentConfig(LedBannerConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastConfig, config.toJson());
    } catch (_) {}
  }

  static Future<LedBannerConfig?> loadCurrentConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyLastConfig);
      if (raw != null && raw.isNotEmpty) {
        return LedBannerConfig.fromJson(raw);
      }
    } catch (_) {}
    return null;
  }

  static Future<List<LedBannerConfig>> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyFavorites);
      if (list != null && list.isNotEmpty) {
        return list
            .map((str) => LedBannerConfig.fromJson(str))
            .toList();
      }
    } catch (_) {}
    return LedBannerConfig.defaultPresets;
  }

  static Future<void> saveFavorites(List<LedBannerConfig> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = favorites.map((cfg) => cfg.toJson()).toList();
      await prefs.setStringList(_keyFavorites, list);
    } catch (_) {}
  }

  static Future<void> addFavorite(LedBannerConfig config) async {
    final favorites = await loadFavorites();
    favorites.insert(0, config.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString()));
    await saveFavorites(favorites);
  }

  static Future<void> removeFavorite(String id) async {
    final favorites = await loadFavorites();
    favorites.removeWhere((item) => item.id == id);
    await saveFavorites(favorites);
  }
}
