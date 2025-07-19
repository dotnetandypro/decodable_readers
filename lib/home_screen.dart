import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/webview_screen.dart';
import '../screens/games_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Decodable Reader'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'games':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GamesScreen(),
                    ),
                  );
                  break;
                case 'privacy':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WebViewScreen(
                        url: 'https://ezlearning.in/PrivacyPolicy.html',
                        title: 'Privacy Policy',
                      ),
                    ),
                  );
                  break;
                case 'terms':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WebViewScreen(
                        url: 'https://ezlearning.in/TermAndCondition.html',
                        title: 'Terms & Conditions',
                      ),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'games',
                child: Row(
                  children: [
                    Icon(Icons.games, color: Color(0xFF6366F1)),
                    SizedBox(width: 12),
                    Text('Educational Games'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'privacy',
                child: Row(
                  children: [
                    Icon(Icons.privacy_tip, color: Color(0xFF6366F1)),
                    SizedBox(width: 12),
                    Text('Privacy Policy'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'terms',
                child: Row(
                  children: [
                    Icon(Icons.description, color: Color(0xFF6366F1)),
                    SizedBox(width: 12),
                    Text('Terms & Conditions'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick access buttons
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickAccessButton(
                    context,
                    'Educational Games',
                    Icons.games,
                    const Color(0xFF10B981),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GamesScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAccessButton(
                    context,
                    'Privacy Policy',
                    Icons.privacy_tip,
                    const Color(0xFF8B5CF6),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WebViewScreen(
                            url: 'https://ezlearning.in/PrivacyPolicy.html',
                            title: 'Privacy Policy',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Reading levels grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.1,
                ),
                itemCount: 10,
                itemBuilder: (context, index) {
                  final level = index + 1;
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/level',
                        arguments: level,
                      );
                    },
                    child: Hero(
                      tag: 'level_$level',
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: AppTheme.getLevelColor(index),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.getLevelColor(index)
                                  .withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_stories,
                                  size: 56, color: Colors.white),
                              const SizedBox(height: 12),
                              Text(
                                'Level $level',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Phonics Set',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white70,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Bottom info section
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WebViewScreen(
                          url: 'https://ezlearning.in/TermAndCondition.html',
                          title: 'Terms & Conditions',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.description, size: 16),
                  label: const Text('Terms'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
                  ),
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: const Color(0xFFE5E7EB),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WebViewScreen(
                          url: 'https://ezlearning.in/PrivacyPolicy.html',
                          title: 'Privacy Policy',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.privacy_tip, size: 16),
                  label: const Text('Privacy'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
