import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// Global orientation service to manage device orientation across the app
class OrientationService {
  static final OrientationService _instance = OrientationService._internal();
  factory OrientationService() => _instance;
  OrientationService._internal();

  static OrientationService get instance => _instance;

  bool _isReadingMode = false;

  /// Force landscape orientation for reading mode - WORKING VERSION
  static Future<void> enterReadingMode() async {
    debugPrint(
        '🚀 OrientationService: ENTERING READING MODE - FORCING LANDSCAPE');

    try {
      // Force landscape with proper await to ensure it works
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      _instance._isReadingMode = true;
      debugPrint(
          '✅ OrientationService: Reading mode activated - landscape locked');
    } catch (error) {
      debugPrint('❌ OrientationService: Failed to enter reading mode: $error');
    }
  }

  /// Exit reading mode and restore all orientations
  static Future<void> exitReadingMode() async {
    debugPrint(
        '🔄 OrientationService: EXITING READING MODE - RESTORING ALL ORIENTATIONS');

    try {
      // Restore all orientations
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      _instance._isReadingMode = false;
      debugPrint(
          '✅ OrientationService: Reading mode deactivated - all orientations restored');
    } catch (error) {
      debugPrint('❌ OrientationService: Failed to exit reading mode: $error');
    }
  }

  /// Check if currently in reading mode
  static bool get isReadingMode => _instance._isReadingMode;

  /// Force landscape with multiple attempts (for stubborn devices like iPad)
  static Future<void> forceAggressiveLandscape() async {
    debugPrint('💪 OrientationService: AGGRESSIVE LANDSCAPE FORCING');

    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        debugPrint('🔄 Attempt $attempt/3: Setting landscape orientation');

        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);

        // Small delay between attempts
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (error) {
        debugPrint('❌ Attempt $attempt failed: $error');
      }
    }

    debugPrint('✅ OrientationService: Aggressive landscape forcing completed');
  }
}
