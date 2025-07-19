import '../models/story_models.dart';

class SampleData {
  static List<Level> getLevels() {
    return [
      // Level 1: s, a, t, p, i, n
      Level(
        id: 1,
        title: 'Level 1',
        description: 'Learning: s, a, t, p, i, n',
        phonicsSet: ['s', 'a', 't', 'p', 'i', 'n'],
        iconPath: 'assets/icons/level1.png',
        storybooks: _getLevel1Stories(),
      ),

      // Level 2: h, d, m, g, o, c, k, ck, e, u, r
      Level(
        id: 2,
        title: 'Level 2',
        description: 'Learning: h, d, m, g, o, c, k, ck, e, u, r',
        phonicsSet: ['h', 'd', 'm', 'g', 'o', 'c', 'k', 'ck', 'e', 'u', 'r'],
        iconPath: 'assets/icons/level2.png',
        storybooks: _getLevel2Stories(),
      ),

      // Level 3: l, f, b, j, v, w, x, y, z, qu
      Level(
        id: 3,
        title: 'Level 3',
        description: 'Learning: l, f, b, j, v, w, x, y, z, qu',
        phonicsSet: ['l', 'f', 'b', 'j', 'v', 'w', 'x', 'y', 'z', 'qu'],
        iconPath: 'assets/icons/level3.png',
        storybooks: _getLevel3Stories(),
      ),

      // Level 4: ll, ff, ss, zz, sh, ch, th, ng
      Level(
        id: 4,
        title: 'Level 4',
        description: 'Learning: ll, ff, ss, zz, sh, ch, th, ng',
        phonicsSet: ['ll', 'ff', 'ss', 'zz', 'sh', 'ch', 'th', 'ng'],
        iconPath: 'assets/icons/level4.png',
        storybooks: _getLevel4Stories(),
      ),

      // Level 5: j, v, w, x, y, z
      Level(
        id: 5,
        title: 'Level 5',
        description: 'Learning: j, v, w, x, y, z',
        phonicsSet: ['j', 'v', 'w', 'x', 'y', 'z'],
        iconPath: 'assets/icons/level5.png',
        storybooks: _getLevel5Stories(),
      ),

      // Level 6: zz, qu, ch, sh, th
      Level(
        id: 6,
        title: 'Level 6',
        description: 'Learning: zz, qu, ch, sh, th',
        phonicsSet: ['zz', 'qu', 'ch', 'sh', 'th'],
        iconPath: 'assets/icons/level6.png',
        storybooks: _getLevel6Stories(),
      ),

      // Level 7: ng, nk, ai, ee, igh
      Level(
        id: 7,
        title: 'Level 7',
        description: 'Learning: ng, nk, ai, ee, igh',
        phonicsSet: ['ng', 'nk', 'ai', 'ee', 'igh'],
        iconPath: 'assets/icons/level7.png',
        storybooks: _getLevel7Stories(),
      ),

      // Level 8: oa, oo, ar, or, ur
      Level(
        id: 8,
        title: 'Level 8',
        description: 'Learning: oa, oo, ar, or, ur',
        phonicsSet: ['oa', 'oo', 'ar', 'or', 'ur'],
        iconPath: 'assets/icons/level8.png',
        storybooks: _getLevel8Stories(),
      ),

      // Level 9: ow, oi, ear, air, ure
      Level(
        id: 9,
        title: 'Level 9',
        description: 'Learning: ow, oi, ear, air, ure',
        phonicsSet: ['ow', 'oi', 'ear', 'air', 'ure'],
        iconPath: 'assets/icons/level9.png',
        storybooks: _getLevel9Stories(),
      ),

      // Level 10: er, mixed review
      Level(
        id: 10,
        title: 'Level 10',
        description: 'Learning: er, mixed review',
        phonicsSet: ['er', 'review'],
        iconPath: 'assets/icons/level10.png',
        storybooks: _getLevel10Stories(),
      ),
    ];
  }

  static List<Storybook> _getLevel1Stories() {
    return List.generate(10, (index) {
      final titles = [
        'Sat the Cat',
        'Pat and Pip',
        'Tin Can',
        'Sit and Spin',
        'Nap Time',
        'Tap Tap',
        'Pin the Tail',
        'Sip and Sit',
        'Ant and Pan',
        'Tip Top'
      ];

      return Storybook(
        id: 'level1_story${index + 1}',
        title: titles[index],
        description: 'A simple story using s, a, t, p, i, n sounds',
        thumbnailPath: 'assets/stories/level1/story${index + 1}/thumbnail.png',
        levelId: 1,
        pages: _generateSamplePages('level1', 'story${index + 1}', 6),
      );
    });
  }

  static List<Storybook> _getLevel2Stories() {
    return List.generate(10, (index) {
      final titles = [
        'Mad Dog',
        'Go Cat Go',
        'Mop and Cod',
        'Dig and Duck',
        'Cog in the Mog',
        'Kick the Can',
        'Dock the Sock',
        'Gum and Mum',
        'Cod and Dog',
        'Mock the Clock'
      ];

      return Storybook(
        id: 'level2_story${index + 1}',
        title: titles[index],
        description: 'Stories with m, d, g, o, c, k sounds',
        thumbnailPath: 'assets/stories/level2/story${index + 1}/thumbnail.png',
        levelId: 2,
        pages: _generateSamplePages('level2', 'story${index + 1}', 8),
      );
    });
  }

  // Generate remaining levels with similar pattern
  static List<Storybook> _getLevel3Stories() {
    return [
      // Sample story for Level 3
      Storybook(
        id: 'level3_story1',
        title: 'Fox and Wolf',
        description: 'A fun story using l, f, b, j, v, w, x, y, z, qu sounds',
        thumbnailPath: 'assets/stories/level3/story1/thumbnail.png',
        levelId: 3,
        pages: [
          StoryPage(
            pageNumber: 1,
            imagePath: 'assets/images/level3/level3_story1_page1.png',
            text: 'Fox jumps over the log.',
            words: ['Fox', 'jumps', 'over', 'the', 'log'],
            audioPath: 'assets/audio/level3/story1/page1.mp3',
          ),
          StoryPage(
            pageNumber: 2,
            imagePath: 'assets/images/level3/level3_story1_page2.png',
            text: 'Wolf walks by the box.',
            words: ['Wolf', 'walks', 'by', 'the', 'box'],
            audioPath: 'assets/audio/level3/story1/page2.mp3',
          ),
          StoryPage(
            pageNumber: 3,
            imagePath: 'assets/images/level3/level3_story1_page3.png',
            text: 'Fox and Wolf play jazz.',
            words: ['Fox', 'and', 'Wolf', 'play', 'jazz'],
            audioPath: 'assets/audio/level3/story1/page3.mp3',
          ),
          StoryPage(
            pageNumber: 4,
            imagePath: 'assets/images/level3/level3_story1_page4.png',
            text: 'They find a big vase.',
            words: ['They', 'find', 'a', 'big', 'vase'],
            audioPath: 'assets/audio/level3/story1/page4.mp3',
          ),
          StoryPage(
            pageNumber: 5,
            imagePath: 'assets/images/level3/level3_story1_page5.png',
            text: 'Wolf asks a quick quiz.',
            words: ['Wolf', 'asks', 'a', 'quick', 'quiz'],
            audioPath: 'assets/audio/level3/story1/page5.mp3',
          ),
          StoryPage(
            pageNumber: 6,
            imagePath: 'assets/images/level3/level3_story1_page6.png',
            text: 'Fox and Wolf are best pals.',
            words: ['Fox', 'and', 'Wolf', 'are', 'best', 'pals'],
            audioPath: 'assets/audio/level3/story1/page6.mp3',
          ),
        ],
        quizGame: QuizGame(
          questions: [
            QuizQuestion(
              question: 'What does Fox jump over?',
              options: ['log', 'box', 'vase', 'quiz'],
              correctAnswer: 'log',
            ),
            QuizQuestion(
              question: 'What do Fox and Wolf play?',
              options: ['box', 'jazz', 'vase', 'quiz'],
              correctAnswer: 'jazz',
            ),
            QuizQuestion(
              question: 'What does Wolf ask?',
              options: ['log', 'box', 'vase', 'quiz'],
              correctAnswer: 'quiz',
            ),
          ],
        ),
      ),
      // Generate additional stories for Level 3
      ...List.generate(9, (index) {
        final titles = [
          'Lazy Fox',
          'Big Wolf',
          'Jazz Box',
          'Quick Vase',
          'Yellow Zebra',
          'Jolly Wolf',
          'Wax Box',
          'Buzzy Fly',
          'Fuzzy Bear'
        ];

        return Storybook(
          id: 'level3_story${index + 2}',
          title: titles[index],
          description:
              'A simple story using l, f, b, j, v, w, x, y, z, qu sounds',
          thumbnailPath:
              'assets/stories/level3/story${index + 2}/thumbnail.png',
          levelId: 3,
          pages: _generateSamplePages('level3', 'story${index + 2}', 6),
        );
      }),
    ];
  }

  static List<Storybook> _getLevel4Stories() {
    return [
      // Sample story for Level 4
      Storybook(
        id: 'level4_story1',
        title: 'The Shell and the Fish',
        description: 'A story using ll, ff, ss, zz, sh, ch, th, ng sounds',
        thumbnailPath: 'assets/stories/level4/story1/thumbnail.png',
        levelId: 4,
        pages: [
          StoryPage(
            pageNumber: 1,
            imagePath: 'assets/images/level4/level4_story1_page1.png',
            text: 'The shell sits on the hill.',
            words: ['The', 'shell', 'sits', 'on', 'the', 'hill'],
            audioPath: 'assets/audio/level4/story1/page1.mp3',
          ),
          StoryPage(
            pageNumber: 2,
            imagePath: 'assets/images/level4/level4_story1_page2.png',
            text: 'A fish swims with a buzz.',
            words: ['A', 'fish', 'swims', 'with', 'a', 'buzz'],
            audioPath: 'assets/audio/level4/story1/page2.mp3',
          ),
          StoryPage(
            pageNumber: 3,
            imagePath: 'assets/images/level4/level4_story1_page3.png',
            text: 'The fish sees the shell.',
            words: ['The', 'fish', 'sees', 'the', 'shell'],
            audioPath: 'assets/audio/level4/story1/page3.mp3',
          ),
          StoryPage(
            pageNumber: 4,
            imagePath: 'assets/images/level4/level4_story1_page4.png',
            text: 'They chat by the thick grass.',
            words: ['They', 'chat', 'by', 'the', 'thick', 'grass'],
            audioPath: 'assets/audio/level4/story1/page4.mp3',
          ),
          StoryPage(
            pageNumber: 5,
            imagePath: 'assets/images/level4/level4_story1_page5.png',
            text: 'The shell tells a long thing.',
            words: ['The', 'shell', 'tells', 'a', 'long', 'thing'],
            audioPath: 'assets/audio/level4/story1/page5.mp3',
          ),
          StoryPage(
            pageNumber: 6,
            imagePath: 'assets/images/level4/level4_story1_page6.png',
            text: 'Fish and shell are pals.',
            words: ['Fish', 'and', 'shell', 'are', 'pals'],
            audioPath: 'assets/audio/level4/story1/page6.mp3',
          ),
        ],
        quizGame: QuizGame(
          questions: [
            QuizQuestion(
              question: 'Where does the shell sit?',
              options: [
                'on the hill',
                'in the grass',
                'by the fish',
                'with the buzz'
              ],
              correctAnswer: 'on the hill',
            ),
            QuizQuestion(
              question: 'What does the fish swim with?',
              options: ['a shell', 'a buzz', 'thick grass', 'a long thing'],
              correctAnswer: 'a buzz',
            ),
            QuizQuestion(
              question: 'Where do they chat?',
              options: [
                'on the hill',
                'by the thick grass',
                'in the shell',
                'with the fish'
              ],
              correctAnswer: 'by the thick grass',
            ),
          ],
        ),
      ),
      // Generate additional stories for Level 4
      ...List.generate(9, (index) {
        final titles = [
          'Stuff and Fluff',
          'The Thick Shell',
          'Buzz and Fizz',
          'Long Song',
          'Chess Match',
          'The Chill Hill',
          'Soft Stuff',
          'Fish Dish',
          'Ring Thing'
        ];

        return Storybook(
          id: 'level4_story${index + 2}',
          title: titles[index],
          description: 'A story using ll, ff, ss, zz, sh, ch, th, ng sounds',
          thumbnailPath:
              'assets/stories/level4/story${index + 2}/thumbnail.png',
          levelId: 4,
          pages: _generateSamplePages('level4', 'story${index + 2}', 6),
        );
      }),
    ];
  }

  static List<Storybook> _getLevel5Stories() {
    return _generateStoriesForLevel(5, 'j, v, w, x, y, z', [
      'Jam and Yam',
      'Van and Win',
      'Wax and Max',
      'Zip and Zap',
      'Jet and Yet',
      'Vat and Wet',
      'Fox in Box',
      'Yes and Yell',
      'Jazz and Buzz',
      'Wag and Zig'
    ]);
  }

  static List<Storybook> _getLevel6Stories() {
    return _generateStoriesForLevel(6, 'zz, qu, ch, sh, th', [
      'Quick Quiz',
      'Chip and Ship',
      'Thin Thing',
      'Chop Shop',
      'Thick Stick',
      'Quack Duck',
      'Shut the Hut',
      'Thump Bump',
      'Chill Hill',
      'Quit Quit'
    ]);
  }

  static List<Storybook> _getLevel7Stories() {
    return _generateStoriesForLevel(7, 'ng, nk, ai, ee, igh', [
      'Ring and Sing',
      'Pink Ink',
      'Rain Train',
      'See the Bee',
      'Night Light',
      'King Wing',
      'Sink Link',
      'Snail Trail',
      'Tree Free',
      'Bright Flight'
    ]);
  }

  static List<Storybook> _getLevel8Stories() {
    return _generateStoriesForLevel(8, 'oa, oo, ar, or, ur', [
      'Boat Float',
      'Moon Spoon',
      'Car Star',
      'For More',
      'Burn Turn',
      'Goat Coat',
      'Zoo Too',
      'Farm Barn',
      'Horn Corn',
      'Surf Turf'
    ]);
  }

  static List<Storybook> _getLevel9Stories() {
    return _generateStoriesForLevel(9, 'ow, oi, ear, air, ure', [
      'Cow Now',
      'Coin Join',
      'Bear Hear',
      'Fair Hair',
      'Pure Sure',
      'Owl Howl',
      'Boil Soil',
      'Dear Near',
      'Chair Stair',
      'Cure Lure'
    ]);
  }

  static List<Storybook> _getLevel10Stories() {
    return _generateStoriesForLevel(10, 'er, mixed review', [
      'Tiger River',
      'Super Paper',
      'Under Thunder',
      'Water Later',
      'Better Letter',
      'Winter Dinner',
      'Summer Hammer',
      'Silver Finger',
      'Monster Center',
      'Master Faster'
    ]);
  }

  static List<Storybook> _generateStoriesForLevel(
      int levelId, String description, List<String> titles) {
    return List.generate(10, (index) {
      return Storybook(
        id: 'level${levelId}_story${index + 1}',
        title: titles[index],
        description: 'Stories with $description sounds',
        thumbnailPath:
            'assets/stories/level$levelId/story${index + 1}/thumbnail.png',
        levelId: levelId,
        pages: _generateSamplePages(
            'level$levelId', 'story${index + 1}', 6 + (levelId * 2)),
      );
    });
  }

  // Helper to generate sample pages for a storybook
  static List<StoryPage> _generateSamplePages(
      String level, String story, int count) {
    return List.generate(
        count,
        (i) => StoryPage(
              pageNumber: i + 1,
              imagePath: 'assets/stories/$level/$story/page${i + 1}.png',
              text: 'Sample text for page ${i + 1} of $story in $level.',
              words: 'Sample text for page ${i + 1} of $story in $level.'
                  .replaceAll(RegExp(r'[^\w\s]'), '')
                  .split(' ')
                  .where((w) => w.isNotEmpty)
                  .toList(),
              audioPath: 'assets/stories/$level/$story/page${i + 1}.mp3',
            ));
  }
}
