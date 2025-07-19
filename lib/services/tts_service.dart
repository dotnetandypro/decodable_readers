import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io' show Platform;

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  static TTSService get instance => _instance;

  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;

  /// Initialize the TTS service with Australian voice settings
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _flutterTts = FlutterTts();

      // Set up TTS configuration for Australian voice
      await _configureTTS();

      // Set up event handlers
      _setupEventHandlers();

      _isInitialized = true;
      debugPrint(
          '✅ TTS Service initialized successfully with Australian voice');
    } catch (e) {
      debugPrint('❌ Failed to initialize TTS Service: $e');
    }
  }

  /// Configure TTS settings for Australian voice
  Future<void> _configureTTS() async {
    if (_flutterTts == null) return;

    try {
      // iOS-specific audio session configuration
      if (Platform.isIOS) {
        await _flutterTts!.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          ],
          IosTextToSpeechAudioMode.spokenAudio,
        );
        debugPrint('🍎 iOS audio session configured for TTS');
      }

      // Set language to Australian English
      await _flutterTts!.setLanguage('en-AU');

      // Set speech rate (0.0 to 1.0, where 0.5 is normal)
      await _flutterTts!.setSpeechRate(0.45); // Slightly slower for children

      // Set volume (0.0 to 1.0)
      await _flutterTts!.setVolume(1.0); // Maximum volume for iOS

      // Set pitch (0.5 to 2.0, where 1.0 is normal)
      await _flutterTts!
          .setPitch(1.1); // Slightly higher pitch for friendliness

      // Try to set Australian voice if available
      await _setAustralianVoice();

      debugPrint('🎙️ TTS configured with Australian settings');
    } catch (e) {
      debugPrint('⚠️ Error configuring TTS: $e');
    }
  }

  /// Attempt to set an Australian voice
  Future<void> _setAustralianVoice() async {
    if (_flutterTts == null) return;

    try {
      // Get available voices
      List<dynamic> voices = await _flutterTts!.getVoices;

      // Look for Australian voices
      Map<String, String>? australianVoice;

      for (dynamic voice in voices) {
        if (voice is Map<String, dynamic>) {
          String? name = voice['name']?.toString();
          String? locale = voice['locale']?.toString();

          debugPrint('🎤 Available voice: $name ($locale)');

          // Prefer Australian English voices
          if (locale != null && locale.toLowerCase().contains('en-au')) {
            australianVoice = {
              'name': name ?? '',
              'locale': locale,
            };
            break;
          }

          // Fallback to other English voices with Australian-sounding names
          if (name != null &&
              (name.toLowerCase().contains('australian') ||
                  name.toLowerCase().contains('aussie') ||
                  name
                      .toLowerCase()
                      .contains('karen') || // Common Australian TTS voice
                  name.toLowerCase().contains('catherine'))) {
            australianVoice = {
              'name': name,
              'locale': locale ?? 'en-AU',
            };
          }
        }
      }

      // Set the Australian voice if found
      if (australianVoice != null) {
        await _flutterTts!.setVoice({
          'name': australianVoice['name']!,
          'locale': australianVoice['locale']!,
        });
        debugPrint(
            '🇦🇺 Set Australian voice: ${australianVoice['name']} (${australianVoice['locale']})');
      } else {
        debugPrint('⚠️ No Australian voice found, using default English voice');
      }
    } catch (e) {
      debugPrint('⚠️ Error setting Australian voice: $e');
    }
  }

  /// Set up event handlers for TTS
  void _setupEventHandlers() {
    if (_flutterTts == null) return;

    _flutterTts!.setStartHandler(() {
      _isSpeaking = true;
      debugPrint('🎙️ TTS started speaking');
    });

    _flutterTts!.setCompletionHandler(() {
      _isSpeaking = false;
      debugPrint('✅ TTS completed speaking');
    });

    _flutterTts!.setErrorHandler((message) {
      _isSpeaking = false;
      debugPrint('❌ TTS error: $message');
    });

    _flutterTts!.setCancelHandler(() {
      _isSpeaking = false;
      debugPrint('🛑 TTS cancelled');
    });
  }

  /// Speak the given text with Australian voice
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      debugPrint('🔄 TTS not initialized, initializing now...');
      await initialize();
    }

    if (_flutterTts == null || text.trim().isEmpty) {
      debugPrint('⚠️ Cannot speak: TTS not initialized or empty text');
      return;
    }

    try {
      // Stop any current speech
      if (_isSpeaking) {
        debugPrint('🛑 Stopping current speech before starting new one');
        await stop();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      debugPrint('🎙️ Speaking with Australian voice: "$text"');
      debugPrint('🔊 Attempting to speak text...');

      final result = await _flutterTts!.speak(text);
      debugPrint('📢 TTS speak result: $result');

      // Test if TTS is actually working
      if (result == 1) {
        debugPrint('✅ TTS speak command successful');
      } else {
        debugPrint('❌ TTS speak command failed with result: $result');
      }
    } catch (e) {
      debugPrint('❌ Error speaking text: $e');
      debugPrint('🔍 Stack trace: ${StackTrace.current}');
    }
  }

  /// Stop current speech
  Future<void> stop() async {
    if (_flutterTts == null) return;

    try {
      await _flutterTts!.stop();
      _isSpeaking = false;
      debugPrint('🛑 TTS stopped');
    } catch (e) {
      debugPrint('❌ Error stopping TTS: $e');
    }
  }

  /// Pause current speech
  Future<void> pause() async {
    if (_flutterTts == null) return;

    try {
      await _flutterTts!.pause();
      debugPrint('⏸️ TTS paused');
    } catch (e) {
      debugPrint('❌ Error pausing TTS: $e');
    }
  }

  /// Check if TTS is currently speaking
  bool get isSpeaking => _isSpeaking;

  /// Check if TTS is initialized
  bool get isInitialized => _isInitialized;

  /// Test TTS with a simple phrase
  Future<void> testTTS() async {
    debugPrint('🧪 Testing TTS functionality...');
    await speak('Testing Australian voice');
  }

  /// Dispose of TTS resources
  Future<void> dispose() async {
    if (_flutterTts != null) {
      await stop();
      _flutterTts = null;
      _isInitialized = false;
      debugPrint('🗑️ TTS Service disposed');
    }
  }

  /// Get available voices for debugging
  Future<List<Map<String, String>>> getAvailableVoices() async {
    if (_flutterTts == null) return [];

    try {
      List<dynamic> voices = await _flutterTts!.getVoices;
      return voices
          .where((voice) => voice is Map<String, dynamic>)
          .map((voice) => {
                'name': voice['name']?.toString() ?? '',
                'locale': voice['locale']?.toString() ?? '',
              })
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting voices: $e');
      return [];
    }
  }
}
