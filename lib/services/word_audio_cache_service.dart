import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class WordAudioCacheService {
  static const String _baseUrl = 'https://ezlearning.in/serve_audio.php';
  static const String _authCode = 'ed404070-1931-47f7-97e5-7bb0f1f93637';
  static const String _cacheDir = 'word_audio';
  
  static Directory? _cacheDirectory;
  static final Map<String, String> _memoryCache = {}; // Maps word to file path
  
  // Initialize cache directory
  static Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDirectory = Directory('${appDir.path}/$_cacheDir');
      
      if (!await _cacheDirectory!.exists()) {
        await _cacheDirectory!.create(recursive: true);
      }
      
      debugPrint('🎵 Word audio cache initialized at: ${_cacheDirectory!.path}');
    } catch (e) {
      debugPrint('❌ Error initializing word audio cache: $e');
    }
  }
  
  // Generate cache key from word
  static String _getCacheKey(String word) {
    final cleanWord = _cleanWord(word);
    final bytes = utf8.encode(cleanWord);
    final digest = md5.convert(bytes);
    return digest.toString();
  }
  
  // Get cached file path
  static String _getCacheFilePath(String cacheKey) {
    return '${_cacheDirectory!.path}/$cacheKey.mp3';
  }
  
  // Clean the word to match the MP3 filename format
  static String _cleanWord(String word) {
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
  
  // Handle special word cases and contractions
  static String _handleSpecialCases(String word) {
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
  
  // Check if word audio exists in cache
  static Future<bool> isWordAudioCached(String word) async {
    if (_cacheDirectory == null) await initialize();
    
    final cleanWord = _cleanWord(word);
    final cacheKey = _getCacheKey(cleanWord);
    
    // Check memory cache first
    if (_memoryCache.containsKey(cleanWord)) {
      return true;
    }
    
    // Check file cache
    final cacheFile = File(_getCacheFilePath(cacheKey));
    return await cacheFile.exists();
  }
  
  // Get cached word audio file path
  static Future<String?> getCachedWordAudioPath(String word) async {
    if (_cacheDirectory == null) await initialize();
    
    final cleanWord = _cleanWord(word);
    final cacheKey = _getCacheKey(cleanWord);
    
    // Check memory cache first
    if (_memoryCache.containsKey(cleanWord)) {
      debugPrint('🎵 Word audio loaded from memory cache: $cleanWord');
      return _memoryCache[cleanWord];
    }
    
    // Check file cache
    final cacheFile = File(_getCacheFilePath(cacheKey));
    if (await cacheFile.exists()) {
      final filePath = cacheFile.path;
      // Store in memory cache for faster access
      _memoryCache[cleanWord] = filePath;
      debugPrint('💾 Word audio loaded from file cache: $cleanWord');
      return filePath;
    }
    
    return null;
  }
  
  // Download and cache word audio
  static Future<String?> downloadAndCacheWordAudio(String word) async {
    if (_cacheDirectory == null) await initialize();
    
    try {
      final cleanWord = _cleanWord(word);
      final url = '$_baseUrl?auth_code=$_authCode&file=$cleanWord.mp3';
      
      debugPrint('🌐 Downloading word audio from: $url');
      
      // Download audio
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final cacheKey = _getCacheKey(cleanWord);
        
        // Save to file cache
        final cacheFile = File(_getCacheFilePath(cacheKey));
        await cacheFile.writeAsBytes(bytes);
        
        final filePath = cacheFile.path;
        
        // Save to memory cache
        _memoryCache[cleanWord] = filePath;
        
        debugPrint('✅ Word audio cached successfully: $cleanWord');
        return filePath;
      } else {
        debugPrint('❌ Failed to download word audio: ${response.statusCode} for $cleanWord');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error downloading word audio: $e');
      return null;
    }
  }
  
  // Get word audio file path (from cache or download)
  static Future<String?> getWordAudioPath(String word) async {
    // First try to get from cache
    final cachedPath = await getCachedWordAudioPath(word);
    if (cachedPath != null) {
      return cachedPath;
    }
    
    // If not in cache, download and cache
    return await downloadAndCacheWordAudio(word);
  }
  
  // Extract all words from a text string
  static List<String> extractWordsFromText(String text) {
    // Split by whitespace and filter out empty strings
    final words = text.split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .map((word) => word.trim())
        .toList();
    
    // Remove duplicates while preserving order
    final uniqueWords = <String>[];
    final seen = <String>{};
    
    for (final word in words) {
      final cleanWord = _cleanWord(word);
      if (cleanWord.isNotEmpty && !seen.contains(cleanWord)) {
        uniqueWords.add(word);
        seen.add(cleanWord);
      }
    }
    
    return uniqueWords;
  }
  
  // Preload word audio for a storybook
  static Future<void> preloadStorybookWordAudio(List<String> allTexts) async {
    try {
      // Extract all unique words from all texts
      final allWords = <String>[];
      for (final text in allTexts) {
        allWords.addAll(extractWordsFromText(text));
      }
      
      // Remove duplicates
      final uniqueWords = allWords.toSet().toList();
      
      debugPrint('🎵 Preloading ${uniqueWords.length} word audio files...');
      
      // Download uncached words in batches to avoid overwhelming the server
      const batchSize = 10;
      for (int i = 0; i < uniqueWords.length; i += batchSize) {
        final batch = uniqueWords.skip(i).take(batchSize).toList();
        
        final futures = batch.map((word) async {
          if (!await isWordAudioCached(word)) {
            await downloadAndCacheWordAudio(word);
          } else {
            debugPrint('⚡ Word audio already cached: ${_cleanWord(word)}');
          }
        });
        
        await Future.wait(futures);
        
        // Small delay between batches to be nice to the server
        if (i + batchSize < uniqueWords.length) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
      
      debugPrint('✅ Word audio preloading completed');
    } catch (e) {
      debugPrint('❌ Error preloading word audio: $e');
    }
  }
  
  // Clear word audio cache
  static Future<void> clearCache() async {
    if (_cacheDirectory == null) await initialize();
    
    try {
      // Clear memory cache
      _memoryCache.clear();
      
      // Clear file cache
      if (await _cacheDirectory!.exists()) {
        await _cacheDirectory!.delete(recursive: true);
        await _cacheDirectory!.create(recursive: true);
      }
      
      debugPrint('🗑️ Word audio cache cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing word audio cache: $e');
    }
  }
  
  // Get cache size
  static Future<int> getCacheSize() async {
    if (_cacheDirectory == null) await initialize();
    
    int totalSize = 0;
    
    try {
      if (await _cacheDirectory!.exists()) {
        final files = _cacheDirectory!.listSync();
        for (final file in files) {
          if (file is File) {
            final stat = await file.stat();
            totalSize += stat.size;
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error calculating word audio cache size: $e');
    }
    
    return totalSize;
  }
  
  // Get cache info for debugging
  static Future<Map<String, dynamic>> getCacheInfo() async {
    final size = await getCacheSize();
    final fileCount = _cacheDirectory != null && await _cacheDirectory!.exists()
        ? _cacheDirectory!.listSync().length
        : 0;
    
    return {
      'memoryCache': _memoryCache.length,
      'fileCache': fileCount,
      'totalSize': size,
      'sizeFormatted': '${(size / 1024 / 1024).toStringAsFixed(2)} MB',
    };
  }
}
