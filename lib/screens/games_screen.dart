import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'webview_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  // List of available games with their actual game icons from assets/gameicons/
  static const List<Map<String, String>> games = [
    {
      'name': 'Animal Game',
      'icon': 'animal',
      'description': 'Learn about animals',
    },
    {
      'name': 'Domino Game',
      'icon': 'domino',
      'description': 'Play with dominoes',
    },
    {
      'name': 'Flags Game',
      'icon': 'flags',
      'description': 'Learn world flags',
    },
    {
      'name': 'Guess Word',
      'icon': 'guessword',
      'description': 'Guess the word',
    },
    {
      'name': 'Instrument Game',
      'icon': 'instrument',
      'description': 'Learn instruments',
    },
    {
      'name': 'Math Game',
      'icon': 'math',
      'description': 'Practice math skills',
    },
    {
      'name': 'Paw Game',
      'icon': 'paw',
      'description': 'Animal paw matching',
    },
    {
      'name': 'Time Game',
      'icon': 'time',
      'description': 'Learn to tell time',
    },
    {
      'name': 'Triangle Game',
      'icon': 'triangle',
      'description': 'Shape recognition',
    },
    {
      'name': 'Words Game',
      'icon': 'words',
      'description': 'Word building fun',
    },
    {
      'name': 'Word Search',
      'icon': 'wordsearch',
      'description': 'Find hidden words',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Educational Games',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6366F1),
              Color(0xFFF8F9FA),
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Choose a Game to Play!',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: AnimationLimiter(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: games.length,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 600),
                          columnCount: 3,
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _buildGameCard(context, games[index]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, Map<String, String> game) {
    return GestureDetector(
      onTap: () {
        final gameUrl = 'https://ezlearning.in/games/${game['icon']}';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(
              url: gameUrl,
              title: game['name']!,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/gameicons/${game['icon']}.png',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                      if (frame != null) {
                        print(
                            '✅ Successfully loaded game icon: assets/gameicons/${game['icon']}.png');
                      }
                      return child;
                    },
                    errorBuilder: (context, error, stackTrace) {
                      // Debug: Print error details
                      print(
                          '🚨 Failed to load game icon: assets/gameicons/${game['icon']}.png');
                      print('🚨 Error: $error');

                      // Fallback to icon if image fails to load
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getGameIcon(game['icon']!),
                          size: 40,
                          color: const Color(0xFF6366F1),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  game['name']!,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getGameIcon(String iconName) {
    switch (iconName) {
      case 'memory':
        return Icons.psychology;
      case 'wordpuzzle':
        return Icons.extension;
      case 'mathquiz':
        return Icons.calculate;
      case 'spellingbee':
        return Icons.spellcheck;
      case 'readinggame':
        return Icons.menu_book;
      case 'phonicsfun':
        return Icons.hearing;
      case 'lettermatch':
        return Icons.text_fields;
      case 'storybuilder':
        return Icons.auto_stories;
      default:
        return Icons.games;
    }
  }
}
