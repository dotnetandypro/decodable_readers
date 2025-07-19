import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class CoverImageCacheService {
  static const String _baseUrl = 'https://ezlearning.in/get_cover.php';
  static const String _authCode = 'ed404070-1931-47f7-97e5-7bb0f1f93637';
  static const String _cacheDir = 'cover_images';
  
  static Directory? _cacheDirectory;
  static final Map<String, Uint8List> _memoryCache = {};
  
  // Initialize cache directory
  static Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDirectory = Directory('${appDir.path}/$_cacheDir');
      
      if (!await _cacheDirectory!.exists()) {
        await _cacheDirectory!.create(recursive: true);
      }
      
      debugPrint('📁 Cover image cache initialized at: ${_cacheDirectory!.path}');
    } catch (e) {
      debugPrint('Error initializing cover image cache: $e');
    }
  }
  
  // Generate cache key from image path
  static String _getCacheKey(String imagePath) {
    final bytes = utf8.encode(imagePath);
    final digest = md5.convert(bytes);
    return digest.toString();
  }
  
  // Get cached file path
  static String _getCacheFilePath(String cacheKey) {
    return '${_cacheDirectory!.path}/$cacheKey.png';
  }
  
  // Check if cover image exists in cache
  static Future<bool> isCoverImageCached(String imagePath) async {
    if (_cacheDirectory == null) await initialize();
    
    // Check memory cache first
    final cacheKey = _getCacheKey(imagePath);
    if (_memoryCache.containsKey(cacheKey)) {
      return true;
    }
    
    // Check file cache
    final cacheFile = File(_getCacheFilePath(cacheKey));
    return await cacheFile.exists();
  }
  
  // Get cover image from cache
  static Future<Uint8List?> getCachedCoverImage(String imagePath) async {
    if (_cacheDirectory == null) await initialize();
    
    final cacheKey = _getCacheKey(imagePath);
    
    // Check memory cache first
    if (_memoryCache.containsKey(cacheKey)) {
      debugPrint('📱 Cover image loaded from memory cache: $imagePath');
      return _memoryCache[cacheKey];
    }
    
    // Check file cache
    final cacheFile = File(_getCacheFilePath(cacheKey));
    if (await cacheFile.exists()) {
      try {
        final bytes = await cacheFile.readAsBytes();
        // Store in memory cache for faster access
        _memoryCache[cacheKey] = bytes;
        debugPrint('💾 Cover image loaded from file cache: $imagePath');
        return bytes;
      } catch (e) {
        debugPrint('Error reading cached cover image: $e');
      }
    }
    
    return null;
  }
  
  // Download and cache cover image
  static Future<Uint8List?> downloadAndCacheCoverImage(String imagePath) async {
    if (_cacheDirectory == null) await initialize();
    
    try {
      // Construct the URL
      final url = '$_baseUrl?auth_code=$_authCode&file=$imagePath';
      
      debugPrint('🌐 Downloading cover image from: $url');
      
      // Download image
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final cacheKey = _getCacheKey(imagePath);
        
        // Save to file cache
        final cacheFile = File(_getCacheFilePath(cacheKey));
        await cacheFile.writeAsBytes(bytes);
        
        // Save to memory cache
        _memoryCache[cacheKey] = bytes;
        
        debugPrint('✅ Cover image cached successfully: $imagePath');
        return bytes;
      } else {
        debugPrint('❌ Failed to download cover image: ${response.statusCode} for $imagePath');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error downloading cover image: $e');
      return null;
    }
  }
  
  // Get cover image (from cache or download)
  static Future<Uint8List?> getCoverImage(String imagePath) async {
    // First try to get from cache
    final cachedImage = await getCachedCoverImage(imagePath);
    if (cachedImage != null) {
      return cachedImage;
    }
    
    // If not in cache, download and cache
    return await downloadAndCacheCoverImage(imagePath);
  }
  
  // Preload cover images for a level
  static Future<void> preloadLevelCoverImages(List<String> imagePaths) async {
    debugPrint('📚 Preloading ${imagePaths.length} cover images...');
    
    final futures = imagePaths.map((imagePath) async {
      if (!await isCoverImageCached(imagePath)) {
        await downloadAndCacheCoverImage(imagePath);
      } else {
        debugPrint('⚡ Cover image already cached: $imagePath');
      }
    });
    
    await Future.wait(futures);
    debugPrint('✅ Cover image preloading completed');
  }
  
  // Generate cover image path for a storybook
  static String generateCoverImagePath(int levelId, String storybookId) {
    return 'images/level$levelId/$storybookId.png';
  }
  
  // Clear cover image cache
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
      
      debugPrint('🗑️ Cover image cache cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing cover image cache: $e');
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
      debugPrint('❌ Error calculating cover image cache size: $e');
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
