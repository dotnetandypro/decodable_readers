import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/story_models.dart';
import 'settings_service.dart';

class SettingsLoader {
  static Future<List<Level>> loadLevelsFromSettings() async {
    try {
      // Get settings from SettingsService (which loads from remote)
      await SettingsService.instance.loadSettings();
      final Map<String, dynamic>? jsonData = SettingsService.instance.settings;

      if (jsonData == null) {
        debugPrint('❌ No settings available from SettingsService');
        return [];
      }

      final List<dynamic> levelsJson = jsonData['levels'];

      return levelsJson.map((levelJson) {
        final List<dynamic> storybooksJson = levelJson['storybooks'];

        final storybooks = storybooksJson.map((storybookJson) {
          final List<dynamic> pagesJson = storybookJson['pages'];

          final pages = pagesJson.asMap().entries.map((entry) {
            final index = entry.key;
            final pageJson = entry.value;

            return StoryPage.fromText(
              pageNumber: index + 1,
              imagePath: pageJson['image'],
              text: pageJson['text'],
              audioPath:
                  'assets/audio/level${levelJson['id']}/story${storybookJson['id']}/page${index + 1}.mp3',
            );
          }).toList();

          // Create quiz game if it exists
          QuizGame? quizGame;
          if (storybookJson['game'] != null) {
            final gameJson = storybookJson['game'];
            if (gameJson['type'] == 'quiz') {
              final questionsJson = gameJson['questions'] as List<dynamic>;
              final questions = questionsJson.map((questionJson) {
                return QuizQuestion(
                  question: questionJson['question'],
                  options: List<String>.from(questionJson['options']),
                  correctAnswer: questionJson['answer'],
                );
              }).toList();

              quizGame = QuizGame(questions: questions);
            }
          }

          return Storybook(
            id: storybookJson['id'],
            title: storybookJson['title'],
            description: 'A fun story to practice reading',
            thumbnailPath:
                'assets/stories/level${levelJson['id']}/${storybookJson['id']}/thumbnail.png',
            pages: pages,
            levelId: levelJson['id'],
            quizGame: quizGame,
          );
        }).toList();

        return Level(
          id: levelJson['id'],
          title: levelJson['title'],
          description: 'Level ${levelJson['id']} - Reading Practice',
          phonicsSet: _getPhonicsForLevel(levelJson['id']),
          iconPath: 'assets/icons/level${levelJson['id']}.png',
          storybooks: storybooks,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading settings: $e');
      // Return empty list or fallback data
      return [];
    }
  }

  static List<String> _getPhonicsForLevel(int levelId) {
    // Default phonics sets for each level
    const phonicsSets = {
      1: ['s', 'a', 't', 'p', 'i', 'n'],
      2: ['h', 'd', 'm', 'g', 'o', 'c', 'k', 'ck', 'e', 'u', 'r'],
      3: ['l', 'f', 'b', 'j', 'v', 'w', 'x', 'y', 'z', 'qu'],
      4: ['ll', 'ff', 'ss', 'zz', 'sh', 'ch', 'th', 'ng'],
      5: ['j', 'v', 'w', 'x', 'y', 'z'],
      6: ['zz', 'qu', 'ch', 'sh', 'th'],
      7: ['ng', 'nk', 'ai', 'ee', 'igh'],
      8: ['oa', 'oo', 'ar', 'or', 'ur'],
      9: ['ow', 'oi', 'ear', 'air', 'ure'],
      10: ['er', 'review'],
    };

    return phonicsSets[levelId] ?? ['review'];
  }
}
