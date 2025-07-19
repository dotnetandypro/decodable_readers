import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/story_models.dart';
import '../theme/app_theme.dart';
import '../widgets/storybook_card.dart';
import '../widgets/cached_cover_image.dart';
import '../services/orientation_service.dart';
import '../services/progress_service.dart';
import '../services/cover_image_cache_service.dart';
import 'storybook_reader_screen.dart';

class LevelScreen extends StatefulWidget {
  final Level level;

  const LevelScreen({super.key, required this.level});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late Animation<double> _headerSlideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _preloadCoverImages();
  }

  void _setupAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(
      begin: -50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutBack,
    ));

    _headerAnimationController.forward();
  }

  /// Preload all cover images for this level
  Future<void> _preloadCoverImages() async {
    try {
      // Initialize cover image cache service
      await CoverImageCacheService.initialize();

      // Generate cover image paths for all storybooks in this level
      final coverImagePaths = widget.level.storybooks
          .map((storybook) => CoverImageCacheService.generateCoverImagePath(
                storybook.levelId,
                storybook.id,
              ))
          .toList();

      debugPrint(
          '📚 Preloading ${coverImagePaths.length} cover images for ${widget.level.title}');

      // Preload all cover images in background
      CoverImageCacheService.preloadLevelCoverImages(coverImagePaths);

      debugPrint('✅ Cover image preloading started for ${widget.level.title}');
    } catch (e) {
      debugPrint('❌ Failed to preload cover images: $e');
    }
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    super.dispose();
  }

  /// Get grid cross axis count based on device orientation
  /// Portrait: 2 cards per row, Landscape: 4 cards per row
  int _getGridCrossAxisCount(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.landscape ? 4 : 2;
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
    final levelColor = AppTheme.getLevelColor(widget.level.id - 1);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAnimatedHeader(levelColor),
            _buildStorybooksGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader(Color levelColor) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _headerSlideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _headerSlideAnimation.value),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    levelColor,
                    levelColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: -30,
                    bottom: -30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button and level info
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.level.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: _getScaledFontSize(context, 28),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    widget.level.description,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: _getScaledFontSize(context, 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Phonics set
                        Text(
                          'Phonics Sounds:',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: _getScaledFontSize(context, 14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.level.phonicsSet.map((phonic) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                phonic,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: _getScaledFontSize(context, 14),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Progress - using ProgressService
                        _buildProgressSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressSection() {
    // Get real progress from ProgressService
    final completedBooks =
        ProgressService.instance.getBooksCompletedForLevel(widget.level.id);
    final totalBooks = widget.level.storybooks.length;
    final progressPercentage = ProgressService.instance
        .getLevelProgressPercentage(widget.level.id, totalBooks);

    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_stories_rounded,
              color: Colors.white.withOpacity(0.9),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '$completedBooks of $totalBooks books completed',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: _getScaledFontSize(context, 14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressPercentage,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(progressPercentage * 100).toInt()}% Complete',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: _getScaledFontSize(context, 12),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (completedBooks > 0)
              Text(
                '🎉 $completedBooks quiz${completedBooks == 1 ? '' : 'zes'} passed!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: _getScaledFontSize(context, 12),
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStorybooksGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getGridCrossAxisCount(context),
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final storybook = widget.level.storybooks[index];
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 500),
              columnCount: 2,
              child: SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: StorybookCard(
                    storybook: storybook,
                    onTap: () => _navigateToStorybook(storybook),
                  ),
                ),
              ),
            );
          },
          childCount: widget.level.storybooks.length,
        ),
      ),
    );
  }

  void _navigateToStorybook(Storybook storybook) async {
    // Force landscape orientation BEFORE navigation
    await OrientationService.enterReadingMode();

    // Small delay to ensure orientation takes effect
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    // Navigate to storybook and wait for return
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            StorybookReaderScreen(
          storybook: storybook,
          level: widget.level.id,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
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

    // Refresh the UI when returning to show updated progress
    if (mounted) {
      setState(() {
        // This will trigger a rebuild and show updated progress
      });
      debugPrint('📊 Level screen refreshed - progress updated');
    }
  }
}
