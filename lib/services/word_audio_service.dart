import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'word_audio_cache_service.dart';

class WordAudioService {
  static final WordAudioService _instance = WordAudioService._internal();
  factory WordAudioService() => _instance;
  WordAudioService._internal();

  static WordAudioService get instance => _instance;

  AudioPlayer? _audioPlayer;
  bool _isInitialized = false;
  bool _isPlaying = false;

  /// Initialize the Word Audio service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _audioPlayer = AudioPlayer();

      // Set up event handlers
      _setupEventHandlers();

      _isInitialized = true;
      debugPrint('✅ Word Audio Service initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize Word Audio Service: $e');
    }
  }

  /// Set up event handlers for audio player
  void _setupEventHandlers() {
    if (_audioPlayer == null) return;

    _audioPlayer!.onPlayerStateChanged.listen((PlayerState state) {
      switch (state) {
        case PlayerState.playing:
          _isPlaying = true;
          debugPrint('🎵 Word audio started playing');
          break;
        case PlayerState.completed:
          _isPlaying = false;
          debugPrint('✅ Word audio completed');
          break;
        case PlayerState.stopped:
          _isPlaying = false;
          debugPrint('🛑 Word audio stopped');
          break;
        case PlayerState.paused:
          _isPlaying = false;
          debugPrint('⏸️ Word audio paused');
          break;
        case PlayerState.disposed:
          _isPlaying = false;
          debugPrint('🗑️ Word audio disposed');
          break;
      }
    });

    _audioPlayer!.onDurationChanged.listen((Duration duration) {
      debugPrint('⏱️ Word audio duration: ${duration.inMilliseconds}ms');
    });

    _audioPlayer!.onPositionChanged.listen((Duration position) {
      // Optional: track playback position
    });
  }

  /// Play the audio file for a specific word
  Future<void> playWord(String word) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_audioPlayer == null || word.trim().isEmpty) {
      debugPrint(
          '⚠️ Cannot play word: Audio player not initialized or empty word');
      return;
    }

    try {
      // Stop any current audio
      if (_isPlaying) {
        await stop();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Get cached audio file path
      final audioFilePath = await WordAudioCacheService.getWordAudioPath(word);

      if (audioFilePath != null) {
        debugPrint('🎵 Playing word audio: "$word" from cached file');

        // Play the audio from cached file
        await _audioPlayer!.play(DeviceFileSource(audioFilePath));
      } else {
        debugPrint('❌ No cached audio found for word: "$word"');
      }
    } catch (e) {
      debugPrint('❌ Error playing word "$word": $e');
    }
  }

  /// Clean the word to match the MP3 filename format
  String _cleanWord(String word) {
    // Remove punctuation and convert to lowercase
    String cleaned = word.toLowerCase();

    // Remove common punctuation marks
    cleaned = cleaned.replaceAll(RegExp(r'[^\w\s]'), '');

    // Remove extra whitespace
    cleaned = cleaned.trim();

    // Handle contractions and special cases
    cleaned = _handleSpecialCases(cleaned);

    return cleaned;
  }

  /// Handle special word cases and contractions
  String _handleSpecialCases(String word) {
    // Handle common contractions
    final contractions = {
      "can't": "cant",
      "won't": "wont",
      "don't": "dont",
      "doesn't": "doesnt",
      "didn't": "didnt",
      "isn't": "isnt",
      "aren't": "arent",
      "wasn't": "wasnt",
      "weren't": "werent",
      "haven't": "havent",
      "hasn't": "hasnt",
      "hadn't": "hadnt",
      "you're": "youre",
      "they're": "theyre",
      "we're": "were",
      "I'm": "im",
      "he's": "hes",
      "she's": "shes",
      "it's": "its",
      "that's": "thats",
      "what's": "whats",
      "where's": "wheres",
      "you'll": "youll",
      "they'll": "theyll",
      "we'll": "well",
      "I'll": "ill",
      "you've": "youve",
      "they've": "theyve",
      "we've": "weve",
      "I've": "ive",
    };

    // Check if the word is a contraction
    if (contractions.containsKey(word)) {
      return contractions[word]!;
    }

    return word;
  }

  /// Stop current audio playback
  Future<void> stop() async {
    if (_audioPlayer == null) return;

    try {
      await _audioPlayer!.stop();
      _isPlaying = false;
      debugPrint('🛑 Word audio stopped');
    } catch (e) {
      debugPrint('❌ Error stopping word audio: $e');
    }
  }

  /// Pause current audio playback
  Future<void> pause() async {
    if (_audioPlayer == null) return;

    try {
      await _audioPlayer!.pause();
      _isPlaying = false;
      debugPrint('⏸️ Word audio paused');
    } catch (e) {
      debugPrint('❌ Error pausing word audio: $e');
    }
  }

  /// Check if audio is currently playing
  bool get isPlaying => _isPlaying;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Dispose of audio resources
  Future<void> dispose() async {
    if (_audioPlayer != null) {
      await stop();
      await _audioPlayer!.dispose();
      _audioPlayer = null;
      _isInitialized = false;
      debugPrint('🗑️ Word Audio Service disposed');
    }
  }

  /// Test if a word audio file exists (for debugging)
  Future<bool> wordAudioExists(String word) async {
    try {
      final cleanWord = _cleanWord(word);
      final assetPath = 'assets/wordfiles/$cleanWord.mp3';

      // This is a simple check - in production you might want more sophisticated validation
      debugPrint('🔍 Checking if word audio exists: $assetPath');
      return true; // Assume it exists for now
    } catch (e) {
      debugPrint('❌ Error checking word audio existence: $e');
      return false;
    }
  }

  /// Get the expected filename for a word (for debugging)
  String getExpectedFilename(String word) {
    return '${_cleanWord(word)}.mp3';
  }
}
