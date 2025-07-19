import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/story_provider.dart';
import '../models/story_models.dart';
import '../theme/app_theme.dart';
import '../widgets/level_card.dart';
import '../widgets/progress_indicator_widget.dart';
import '../services/progress_service.dart';
import 'level_screen.dart';
import 'webview_screen.dart';
import 'games_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.elasticOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _progressAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  /// Get grid cross axis count based on device orientation
  /// Portrait: 2 cards per row, Landscape: 4 cards per row
  int _getGridCrossAxisCount(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.landscape ? 4 : 2;
  }

  /// Get device-specific aspect ratio for level cards
  /// iPhone gets taller cards (lower ratio) for better phonics display
  double _getCardAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isIPad = screenWidth >= 1024; // iPad detection threshold

    // iPhone gets much taller cards (0.60), iPad uses standard ratio (0.85)
    return isIPad ? 0.85 : 0.60;
  }

  /// Get device-specific font size scaling
  /// iPad gets larger fonts than iPhone for better readability
  double _getScaledFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isIPad = screenWidth >= 1024; // iPad detection threshold

    // iPad gets 1.4x larger fonts, iPhone uses base size
    return isIPad ? baseFontSize * 1.4 : baseFontSize;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Consumer<StoryProvider>(
          builder: (context, storyProvider, child) {
            if (storyProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                _buildAnimatedHeader(storyProvider),
                _buildLevelsGrid(storyProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader(StoryProvider storyProvider) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _headerSlideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _headerSlideAnimation.value),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Decodable Reader',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'Learn to read with phonics!',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppTheme.textPrimary,
                          size: 28,
                        ),
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
                                    url:
                                        'https://ezlearning.in/PrivacyPolicy.html',
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
                                    url:
                                        'https://ezlearning.in/TermAndCondition.html',
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
                                Icon(Icons.games, color: AppTheme.primaryColor),
                                SizedBox(width: 12),
                                Text('Educational Games'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'privacy',
                            child: Row(
                              children: [
                                Icon(Icons.privacy_tip,
                                    color: AppTheme.primaryColor),
                                SizedBox(width: 12),
                                Text('Privacy Policy'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'terms',
                            child: Row(
                              children: [
                                Icon(Icons.description,
                                    color: AppTheme.primaryColor),
                                SizedBox(width: 12),
                                Text('Terms & Conditions'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      final overallProgress =
                          storyProvider.getOverallProgress();
                      final completedBooks =
                          storyProvider.getTotalBooksCompleted();
                      final totalBooks = storyProvider.getTotalBooks();

                      return ProgressIndicatorWidget(
                        progress: overallProgress * _progressAnimation.value,
                        title: 'Overall Progress',
                        subtitle:
                            '$completedBooks of $totalBooks books completed • ${(overallProgress * 100).toInt()}% Complete',
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Quick access button
                  _buildQuickAccessButton(
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
                  const SizedBox(height: 16),
                  // Footer links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WebViewScreen(
                                url:
                                    'https://ezlearning.in/TermAndCondition.html',
                                title: 'Terms & Conditions',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.description, size: 16),
                        label: const Text('Terms'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        color: AppTheme.textSecondary.withValues(alpha: 0.3),
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
                          foregroundColor: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelsGrid(StoryProvider storyProvider) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getGridCrossAxisCount(context),
          childAspectRatio: _getCardAspectRatio(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final level = storyProvider.levels[index];
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 600),
              columnCount: 2,
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Hero(
                    tag: 'level_${level.id}',
                    child: LevelCard(
                      level: level,
                      onTap: () => _navigateToLevel(level),
                    ),
                  ),
                ),
              ),
            );
          },
          childCount: storyProvider.levels.length,
        ),
      ),
    );
  }

  void _navigateToLevel(Level level) async {
    // Navigate to level screen and wait for return
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            LevelScreen(level: level),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );

    // Refresh the home screen to show updated progress
    if (mounted) {
      setState(() {
        // This will trigger a rebuild and show updated progress
      });
      debugPrint('📊 Home screen refreshed - overall progress updated');
    }
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
