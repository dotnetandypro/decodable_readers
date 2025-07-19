import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

class SettingsService {
  static SettingsService? _instance;
  static SettingsService get instance => _instance ??= SettingsService._();

  SettingsService._();

  Map<String, dynamic>? _settings;

  Future<void> loadSettings() async {
    if (_settings != null) return;

    try {
      final String settingsString =
          await rootBundle.loadString('assets/settings.json');
      _settings = json.decode(settingsString);
      print('✅ Settings loaded successfully');
    } catch (e) {
      print('Error loading settings: $e');
      _settings = _getDefaultSettings();
    }
  }

  /// Force reload settings from assets (useful for development)
  Future<void> reloadSettings() async {
    _settings = null; // Clear cached settings
    await loadSettings();
    print('🔄 Settings reloaded from assets');
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
      print('⚠️ Settings not loaded, using default font size');
      return 18.0; // Default font size
    }

    // Detect device type and use appropriate font settings
    final bool isIPad = _isIPad(screenWidth: screenWidth);
    final String fontSettingsKey =
        isIPad ? 'fontSettingsIpad' : 'fontSettingsIphone';

    print(
        '📱 Device detected: ${isIPad ? 'iPad' : 'iPhone'} (screenWidth: $screenWidth)');
    print('🔑 Using font settings key: $fontSettingsKey');

    final fontSettings = _settings![fontSettingsKey] as Map<String, dynamic>?;
    if (fontSettings == null) {
      print('⚠️ Font settings not found for $fontSettingsKey, trying fallback');
      // Fallback to the other device type if current one is not found
      final fallbackKey = isIPad ? 'fontSettingsIphone' : 'fontSettingsIpad';
      final fallbackSettings = _settings![fallbackKey] as Map<String, dynamic>?;
      if (fallbackSettings != null) {
        final fontSize = fallbackSettings['level$level'];
        print('📏 Using fallback font size for level $level: $fontSize');
        if (fontSize is int) return fontSize.toDouble();
        if (fontSize is double) return fontSize;
      }
      return 18.0;
    }

    final fontSize = fontSettings['level$level'];
    print('📏 Font size for level $level: $fontSize');

    if (fontSize is int) {
      return fontSize.toDouble();
    } else if (fontSize is double) {
      return fontSize;
    }

    print('⚠️ Invalid font size for level $level, using default');
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
