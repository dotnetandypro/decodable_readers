import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

/// Service to track and persist user progress across levels and books
class ProgressService {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  static ProgressService get instance => _instance;

  // Keys for SharedPreferences
  static const String _progressKey = 'user_progress';
  static const String _completedBooksKey = 'completed_books';
  
  // In-memory cache
  Map<int, int> _levelProgress = {}; // level_id -> number of books completed
  Set<String> _completedBooks = {}; // Set of completed book IDs
  
  /// Initialize the progress service and load saved data
  Future<void> initialize() async {
    await _loadProgress();
    debugPrint('📊 ProgressService initialized');
    debugPrint('📈 Current progress: $_levelProgress');
    debugPrint('📚 Completed books: ${_completedBooks.length}');
  }
  
  /// Load progress from SharedPreferences
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load level progress
      final progressJson = prefs.getString(_progressKey);
      if (progressJson != null) {
        final Map<String, dynamic> progressMap = json.decode(progressJson);
        _levelProgress = progressMap.map((key, value) => MapEntry(int.parse(key), value as int));
      }
      
      // Load completed books
      final completedBooksJson = prefs.getString(_completedBooksKey);
      if (completedBooksJson != null) {
        final List<dynamic> booksList = json.decode(completedBooksJson);
        _completedBooks = booksList.cast<String>().toSet();
      }
      
      debugPrint('✅ Progress loaded from device storage');
    } catch (error) {
      debugPrint('❌ Failed to load progress: $error');
      _levelProgress = {};
      _completedBooks = {};
    }
  }
  
  /// Save progress to SharedPreferences
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save level progress
      final progressMap = _levelProgress.map((key, value) => MapEntry(key.toString(), value));
      await prefs.setString(_progressKey, json.encode(progressMap));
      
      // Save completed books
      await prefs.setString(_completedBooksKey, json.encode(_completedBooks.toList()));
      
      debugPrint('💾 Progress saved to device storage');
    } catch (error) {
      debugPrint('❌ Failed to save progress: $error');
    }
  }
  
  /// Mark a book as completed and update level progress
  Future<void> completeBook(String bookId, int levelId) async {
    debugPrint('🎉 Completing book: $bookId for level: $levelId');
    
    // Check if book was already completed
    if (_completedBooks.contains(bookId)) {
      debugPrint('📚 Book $bookId already completed, skipping progress update');
      return;
    }
    
    // Mark book as completed
    _completedBooks.add(bookId);
    
    // Update level progress
    _levelProgress[levelId] = (_levelProgress[levelId] ?? 0) + 1;
    
    debugPrint('📈 Level $levelId progress updated: ${_levelProgress[levelId]} books completed');
    
    // Save to device
    await _saveProgress();
    
    debugPrint('✅ Book completion saved successfully');
  }
  
  /// Get the number of books completed for a specific level
  int getBooksCompletedForLevel(int levelId) {
    return _levelProgress[levelId] ?? 0;
  }
  
  /// Get the total number of books completed across all levels
  int getTotalBooksCompleted() {
    return _completedBooks.length;
  }
  
  /// Check if a specific book has been completed
  bool isBookCompleted(String bookId) {
    return _completedBooks.contains(bookId);
  }
  
  /// Get progress percentage for a level (requires total books count)
  double getLevelProgressPercentage(int levelId, int totalBooksInLevel) {
    if (totalBooksInLevel == 0) return 0.0;
    final completed = getBooksCompletedForLevel(levelId);
    return (completed / totalBooksInLevel).clamp(0.0, 1.0);
  }
  
  /// Get all level progress data
  Map<int, int> getAllLevelProgress() {
    return Map.from(_levelProgress);
  }
  
  /// Reset progress for a specific level
  Future<void> resetLevelProgress(int levelId) async {
    debugPrint('🔄 Resetting progress for level: $levelId');
    
    // Remove completed books for this level (would need book-to-level mapping)
    // For now, just reset the level progress count
    _levelProgress[levelId] = 0;
    
    await _saveProgress();
    debugPrint('✅ Level $levelId progress reset');
  }
  
  /// Reset all progress
  Future<void> resetAllProgress() async {
    debugPrint('🔄 Resetting all progress');
    
    _levelProgress.clear();
    _completedBooks.clear();
    
    await _saveProgress();
    debugPrint('✅ All progress reset');
  }
  
  /// Get progress summary for debugging
  String getProgressSummary() {
    final totalBooks = getTotalBooksCompleted();
    final levels = _levelProgress.keys.toList()..sort();
    
    String summary = '📊 Progress Summary:\n';
    summary += '📚 Total books completed: $totalBooks\n';
    
    for (final levelId in levels) {
      final count = _levelProgress[levelId]!;
      summary += '📖 Level $levelId: $count books completed\n';
    }
    
    return summary;
  }
}
