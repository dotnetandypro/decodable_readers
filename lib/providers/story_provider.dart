import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/story_models.dart';
import '../services/settings_loader.dart';
import '../services/progress_service.dart';

class StoryProvider extends ChangeNotifier {
  List<Level> _levels = [];
  Map<String, ReadingProgress> _readingProgress = {};
  bool _isLoading = true;

  List<Level> get levels => _levels;
  bool get isLoading => _isLoading;

  StoryProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Load data from settings.json
      _levels = await SettingsLoader.loadLevelsFromSettings();

      // Load saved progress
      await _loadProgress();

      // Apply progress to storybooks
      _applyProgressToStorybooks();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString('reading_progress');

      if (progressJson != null) {
        final Map<String, dynamic> progressMap = json.decode(progressJson);
        _readingProgress = progressMap.map(
          (key, value) => MapEntry(
            key,
            ReadingProgress.fromJson(value as Map<String, dynamic>),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error loading progress: $e');
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressMap = _readingProgress.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      await prefs.setString('reading_progress', json.encode(progressMap));
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  void _applyProgressToStorybooks() {
    for (final level in _levels) {
      for (final storybook in level.storybooks) {
        final progress = _readingProgress[storybook.id];
        if (progress != null) {
          storybook.currentPage = progress.currentPage;
          storybook.isCompleted = progress.isCompleted;
        }
      }
    }
  }

  Level? getLevelById(int levelId) {
    try {
      return _levels.firstWhere((level) => level.id == levelId);
    } catch (e) {
      return null;
    }
  }

  Storybook? getStorybookById(String storybookId) {
    for (final level in _levels) {
      try {
        return level.storybooks.firstWhere((book) => book.id == storybookId);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  Future<void> updateReadingProgress(
      String storybookId, int currentPage) async {
    final storybook = getStorybookById(storybookId);
    if (storybook == null) return;

    // Update storybook progress
    storybook.updateProgress(currentPage);

    // Update reading progress map
    _readingProgress[storybookId] = ReadingProgress(
      storybookId: storybookId,
      currentPage: storybook.currentPage,
      isCompleted: storybook.isCompleted,
      lastRead: DateTime.now(),
    );

    // Save progress
    await _saveProgress();
    notifyListeners();
  }

  Future<void> markStorybookCompleted(String storybookId) async {
    final storybook = getStorybookById(storybookId);
    if (storybook == null) return;

    storybook.markAsCompleted();

    _readingProgress[storybookId] = ReadingProgress(
      storybookId: storybookId,
      currentPage: storybook.currentPage,
      isCompleted: true,
      lastRead: DateTime.now(),
    );

    await _saveProgress();
    notifyListeners();
  }

  List<Storybook> getRecentlyRead({int limit = 5}) {
    final recentBooks = <Storybook>[];

    // Get all storybooks with progress
    final progressEntries = _readingProgress.entries.toList();
    progressEntries
        .sort((a, b) => b.value.lastRead.compareTo(a.value.lastRead));

    for (final entry in progressEntries.take(limit)) {
      final storybook = getStorybookById(entry.key);
      if (storybook != null) {
        recentBooks.add(storybook);
      }
    }

    return recentBooks;
  }

  double getOverallProgress() {
    if (_levels.isEmpty) return 0.0;

    int totalBooks = 0;
    int completedBooks = 0;

    for (final level in _levels) {
      totalBooks += level.storybooks.length;
      // Use ProgressService to get real completed books count
      completedBooks +=
          ProgressService.instance.getBooksCompletedForLevel(level.id);
    }

    return totalBooks > 0 ? completedBooks / totalBooks : 0.0;
  }

  /// Get total number of books completed across all levels
  int getTotalBooksCompleted() {
    return ProgressService.instance.getTotalBooksCompleted();
  }

  /// Get total number of books across all levels
  int getTotalBooks() {
    return _levels.fold(0, (total, level) => total + level.storybooks.length);
  }
}
