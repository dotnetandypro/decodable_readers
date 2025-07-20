import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class SettingsService {
  static const String _settingsUrl = 'https://ezlearning.in/settings.json';
  static const String _cacheFileName = 'settings_cache.json';

  static SettingsService? _instance;
  static SettingsService get instance => _instance ??= SettingsService._();

  SettingsService._();

  Map<String, dynamic>? _settings;
  File? _cacheFile;

  Future<void> loadSettings() async {
    if (_settings != null) return;

    try {
      // Initialize cache file
      await _initializeCacheFile();

      // Try to load from remote first
      final remoteSettings = await _loadFromRemote();
      if (remoteSettings != null) {
        _settings = remoteSettings;
        await _saveToCache(remoteSettings);
        debugPrint('✅ Settings loaded from remote server');
        return;
      }

      // If remote fails, try to load from cache
      final cachedSettings = await _loadFromCache();
      if (cachedSettings != null) {
        _settings = cachedSettings;
        debugPrint('📱 Settings loaded from cache (offline mode)');
        return;
      }

      // If both fail, use default settings
      _settings = _getDefaultSettings();
      debugPrint('⚠️ Using default settings (no remote or cache available)');
    } catch (e) {
      debugPrint('❌ Error loading settings: $e');
      _settings = _getDefaultSettings();
    }
  }

  /// Initialize cache file
  Future<void> _initializeCacheFile() async {
    if (_cacheFile != null) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheFile = File('${appDir.path}/$_cacheFileName');
    } catch (e) {
      debugPrint('❌ Error initializing cache file: $e');
    }
  }

  /// Load settings from remote server
  Future<Map<String, dynamic>?> _loadFromRemote() async {
    try {
      debugPrint('🌐 Loading settings from: $_settingsUrl');

      final response = await http.get(
        Uri.parse(_settingsUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final settings = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('✅ Settings downloaded successfully');
        return settings;
      } else {
        debugPrint('❌ Failed to load settings: HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error loading settings from remote: $e');
      return null;
    }
  }

  /// Load settings from cache
  Future<Map<String, dynamic>?> _loadFromCache() async {
    try {
      if (_cacheFile == null || !await _cacheFile!.exists()) {
        return null;
      }

      final cacheContent = await _cacheFile!.readAsString();
      final settings = json.decode(cacheContent) as Map<String, dynamic>;
      debugPrint('📱 Settings loaded from cache');
      return settings;
    } catch (e) {
      debugPrint('❌ Error loading settings from cache: $e');
      return null;
    }
  }

  /// Save settings to cache
  Future<void> _saveToCache(Map<String, dynamic> settings) async {
    try {
      if (_cacheFile == null) return;

      final settingsJson = json.encode(settings);
      await _cacheFile!.writeAsString(settingsJson);
      debugPrint('💾 Settings cached successfully');
    } catch (e) {
      debugPrint('❌ Error saving settings to cache: $e');
    }
  }

  /// Force reload settings from remote (useful for development)
  Future<void> reloadSettings() async {
    _settings = null; // Clear cached settings
    await loadSettings();
    debugPrint('🔄 Settings reloaded from remote');
  }

  Map<String, dynamic> _getDefaultSettings() {
    return {
      'fontSettingsIphone': {
        'level1': 24,
        'level2': 22,
        'level3': 20,
        'level4': 18,
        'level5': 14,
        'level6': 13,
        'level7': 12,
        'level8': 11,
        'level9': 11,
        'level10': 11,
      },
      'fontSettingsIpad': {
        'level1': 34,
        'level2': 32,
        'level3': 30,
        'level4': 28,
        'level5': 26,
        'level6': 25,
        'level7': 24,
        'level8': 23,
        'level9': 22,
        'level10': 21,
      }
    };
  }

  double getFontSizeForLevel(int level, {double? screenWidth}) {
    if (_settings == null) {
      debugPrint('⚠️ Settings not loaded, using default font size');
      return 18.0; // Default font size
    }

    // Detect device type and use appropriate font settings
    final bool isIPad = _isIPad(screenWidth: screenWidth);
    final String fontSettingsKey =
        isIPad ? 'fontSettingsIpad' : 'fontSettingsIphone';

    debugPrint(
        '📱 Device detected: ${isIPad ? 'iPad' : 'iPhone'} (screenWidth: $screenWidth)');
    debugPrint('🔑 Using font settings key: $fontSettingsKey');

    final fontSettings = _settings![fontSettingsKey] as Map<String, dynamic>?;
    if (fontSettings == null) {
      debugPrint(
          '⚠️ Font settings not found for $fontSettingsKey, trying fallback');
      // Fallback to the other device type if current one is not found
      final fallbackKey = isIPad ? 'fontSettingsIphone' : 'fontSettingsIpad';
      final fallbackSettings = _settings![fallbackKey] as Map<String, dynamic>?;
      if (fallbackSettings != null) {
        final fontSize = fallbackSettings['level$level'];
        debugPrint('📏 Using fallback font size for level $level: $fontSize');
        if (fontSize is int) return fontSize.toDouble();
        if (fontSize is double) return fontSize;
      }
      return 18.0;
    }

    final fontSize = fontSettings['level$level'];
    debugPrint('📏 Font size for level $level: $fontSize');

    if (fontSize is int) {
      return fontSize.toDouble();
    } else if (fontSize is double) {
      return fontSize;
    }

    debugPrint('⚠️ Invalid font size for level $level, using default');
    return 18.0; // Default fallback
  }

  /// Detect if the current device is an iPad
  bool _isIPad({double? screenWidth}) {
    try {
      // Check if running on iOS
      if (Platform.isIOS) {
        // Use screen width to detect iPad vs iPhone
        if (screenWidth != null) {
          // iPad screens in landscape are typically 1024+ logical pixels wide
          // iPhone screens in landscape are typically 667-932 logical pixels wide
          // iPhone 14 Pro Max landscape: 932px
          // iPad Mini landscape: 1024px
          return screenWidth >=
              1024; // More accurate threshold for iPad detection
        }

        // If no screen width provided, default to iPhone settings
        // This ensures compatibility if screen width detection fails
        return false;
      }
      return false;
    } catch (e) {
      // If Platform detection fails, default to iPhone settings
      return false;
    }
  }

  Map<String, dynamic>? get settings => _settings;
}
