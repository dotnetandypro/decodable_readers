import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'dart:ui' as ui;
import '../models/story_models.dart';
import '../widgets/page_flip_widget.dart';
import '../screens/quiz_game_screen.dart';
import '../services/settings_service.dart';
import '../services/orientation_service.dart';
import '../services/tts_service.dart';
import '../services/word_audio_service.dart';
import '../services/image_cache_service.dart';
import '../theme/app_theme.dart';

class StorybookReaderScreen extends StatefulWidget {
  final Storybook storybook;
  final int level;

  const StorybookReaderScreen({
    super.key,
    required this.storybook,
    required this.level,
  });

  @override
  State<StorybookReaderScreen> createState() => _StorybookReaderScreenState();
}

// Static method to force landscape BEFORE creating the widget
void _forceGlobalLandscape() {
  debugPrint(
      '🌍 GLOBAL orientation lock - forcing landscape BEFORE widget creation');
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}

class _StorybookReaderScreenState extends State<StorybookReaderScreen>
    with TickerProviderStateMixin {
  int _currentPageIndex = 0;
  late AnimationController _fadeController;
  late AnimationController _pageFlipController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pageFlipAnimation;
  bool _isFlipping = false;
  bool _isFlippingBackward = false; // Track flip direction

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.storybook.currentPage;

    // Ensure reading mode is active with immediate orientation lock
    _ensureLandscapeMode();

    // Initialize settings service
    SettingsService.instance.loadSettings();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pageFlipController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _pageFlipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageFlipController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();

    // Initialize TTS service with Australian voice
    _initializeTTS();

    // Initialize Word Audio service for word pronunciation
    _initializeWordAudio();

    // Preload all images for this storybook
    _preloadStoryImages();
  }

  /// Initialize Text-to-Speech service
  Future<void> _initializeTTS() async {
    try {
      await TTSService.instance.initialize();
      debugPrint('🎙️ TTS Service initialized for storybook reading');
    } catch (e) {
      debugPrint('❌ Failed to initialize TTS Service: $e');
    }
  }

  /// Initialize Word Audio service for word pronunciation
  Future<void> _initializeWordAudio() async {
    try {
      await WordAudioService.instance.initialize();
      debugPrint('🎵 Word Audio Service initialized for word pronunciation');
    } catch (e) {
      debugPrint('❌ Failed to initialize Word Audio Service: $e');
    }
  }

  /// Preload all images for this storybook
  Future<void> _preloadStoryImages() async {
    try {
      // Initialize image cache service
      await ImageCacheService.initialize();

      // Extract all image paths from the storybook
      final imagePaths =
          widget.storybook.pages.map((page) => page.imagePath).toList();

      debugPrint(
          '📚 Preloading ${imagePaths.length} images for storybook: ${widget.storybook.title}');

      // Preload all images
      await ImageCacheService.preloadBookImages(imagePaths);

      debugPrint(
          '✅ All images preloaded for storybook: ${widget.storybook.title}');
    } catch (e) {
      debugPrint('❌ Failed to preload images: $e');
    }
  }

  /// Ensure landscape mode is active with multiple attempts
  void _ensureLandscapeMode() async {
    debugPrint('📱 StorybookReader: Ensuring landscape mode');

    // Multiple attempts to ensure orientation locking works
    for (int i = 0; i < 3; i++) {
      try {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);

        debugPrint('✅ StorybookReader: Landscape attempt ${i + 1}/3 completed');

        // Small delay between attempts
        if (i < 2) await Future.delayed(const Duration(milliseconds: 100));
      } catch (error) {
        debugPrint(
            '❌ StorybookReader: Landscape attempt ${i + 1} failed: $error');
      }
    }

    // Also call the orientation service
    await OrientationService.enterReadingMode();
  }

  @override
  void dispose() {
    // Stop any ongoing TTS speech
    TTSService.instance.stop();

    // Stop any ongoing word audio
    WordAudioService.instance.stop();

    // Exit reading mode and restore all orientations
    OrientationService.exitReadingMode();

    _fadeController.dispose();
    _pageFlipController.dispose();
    super.dispose();
  }

  /// Force landscape orientation for all devices (iPhone, iPad, tablets)
  void _lockToLandscape() async {
    try {
      debugPrint('🔄 Attempting to lock orientation to landscape...');

      // Get current device info
      final mediaQuery = MediaQuery.of(context);
      final isTablet = mediaQuery.size.shortestSide >= 600;
      final deviceType = isTablet ? 'Tablet/iPad' : 'Phone';

      debugPrint(
          '📱 Device type: $deviceType (${mediaQuery.size.width}x${mediaQuery.size.height})');

      // Force landscape orientation with multiple attempts for iPad compatibility
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      debugPrint('✅ First orientation lock attempt completed for $deviceType');

      // Add delay and force another orientation lock for iPad
      await Future.delayed(const Duration(milliseconds: 200));

      // Second attempt - sometimes needed for iPad
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      debugPrint('✅ Second orientation lock attempt completed for $deviceType');

      // Force immediate layout rebuild
      if (mounted) {
        setState(() {});
        debugPrint('🔄 Layout rebuild triggered for $deviceType');
      }

      // Additional delay for iPad to ensure orientation takes effect
      await Future.delayed(const Duration(milliseconds: 300));

      debugPrint('✅ Orientation locking sequence completed for $deviceType');
    } catch (error) {
      debugPrint('❌ Failed to lock orientation: $error');
    }
  }

  /// Additional aggressive orientation forcing for iPad
  void _forceOrientationChange() async {
    try {
      // Wait a bit then try a different approach
      await Future.delayed(const Duration(milliseconds: 500));

      // Try setting to portrait first, then immediately to landscape
      // This sometimes helps "wake up" the orientation system on iPad
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      await Future.delayed(const Duration(milliseconds: 100));

      // Now force back to landscape
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      debugPrint('🔄 Aggressive orientation change completed');
    } catch (error) {
      debugPrint('❌ Failed aggressive orientation change: $error');
    }
  }

  /// Immediate and direct orientation lock - no delays, no async
  void _immediateOrientationLock() {
    debugPrint('🚀 IMMEDIATE orientation lock - forcing landscape NOW');

    // Direct synchronous call - no await, no delays
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]).then((_) {
      debugPrint('✅ IMMEDIATE landscape lock completed');

      // Force another lock after a tiny delay for iPad
      Future.delayed(const Duration(milliseconds: 100), () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]).then((_) {
          debugPrint('✅ SECONDARY landscape lock completed for iPad');
        });
      });
    }).catchError((error) {
      debugPrint('❌ IMMEDIATE orientation lock failed: $error');
    });
  }

  /// Restore all orientations for all devices
  void _restoreAllOrientations() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      debugPrint(
          '✅ Orientation restored for all devices (iPhone, iPad, tablets)');
    } catch (error) {
      debugPrint('❌ Failed to restore orientation: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Force landscape layout regardless of device orientation
    return OrientationBuilder(
      builder: (context, orientation) {
        // Get screen dimensions
        final screenSize = MediaQuery.of(context).size;
        final isPhysicallyLandscape = screenSize.width > screenSize.height;

        debugPrint(
            '📱 Device orientation: $orientation, Physical landscape: $isPhysicallyLandscape');
        debugPrint('📐 Screen size: ${screenSize.width}x${screenSize.height}');

        // Always treat as landscape for book reading - rotate content if needed
        return Scaffold(
          backgroundColor: const Color(0xFFF5F1E8), // Warm paper color
          appBar: AppBar(
            title: Text(
              widget.storybook.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            backgroundColor: Colors.brown[700],
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              if (_isLastPage() && widget.storybook.quizGame != null)
                IconButton(
                  icon: const Icon(Icons.quiz),
                  onPressed: _startQuiz,
                  tooltip: 'Start Quiz',
                ),
            ],
          ),
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Book content with page curl navigation
                  Expanded(
                    child: Stack(
                      children: [
                        // Main content - always use horizontal layout
                        Container(
                          margin: const EdgeInsets.fromLTRB(
                              8, 4, 8, 8), // Much closer to top
                          child: _buildBookLayout(),
                        ),

                        // Page curl navigation overlays
                        _buildPageCurlNavigation(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookLayout() {
    final currentPage = widget.storybook.pages[_currentPageIndex];
    final screenSize = MediaQuery.of(context).size;
    final isPhysicallyLandscape = screenSize.width > screenSize.height;

    debugPrint(
        '📖 Building book layout - Physical landscape: $isPhysicallyLandscape');

    // If device is in portrait, force landscape layout with rotation
    if (!isPhysicallyLandscape) {
      debugPrint('🔄 Device in portrait - applying landscape layout rotation');
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Transform.rotate(
            angle: 1.5708, // 90 degrees in radians (π/2)
            child: SizedBox(
              width: screenSize.height * 0.85, // Slightly smaller to fit better
              height: screenSize.width * 0.75,
              child: _buildPageFlipWidget(),
            ),
          ),
        ),
      );
    }

    // Device is in landscape - use normal layout
    debugPrint('✅ Device in landscape - using normal layout');
    return _buildPageFlipWidget();
  }

  Widget _buildPageFlipWidget() {
    final currentPage = widget.storybook.pages[_currentPageIndex];

    // Special case for first spread (pages 1-2): show both as images
    if (_currentPageIndex == 0) {
      final page1 = widget.storybook.pages[0];
      final page2 = _currentPageIndex + 1 < widget.storybook.pages.length
          ? widget.storybook.pages[1]
          : null;

      return PageFlipWidget(
        leftPage: ImagePageWidget(
          imagePath: page1.imagePath,
          pageNumber: page1.pageNumber,
          onReadAloud: () => _onReadAloud(page1),
        ),
        rightPage: page2 != null
            ? ImagePageWidget(
                imagePath: page2.imagePath,
                pageNumber: page2.pageNumber,
                onReadAloud: () => _onReadAloud(page2),
              )
            : Container(
                color: Colors.white,
                child: const Center(
                  child: Text(
                    'End of Story',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ),
        nextLeftPage: _getNextLeftPage(),
        prevRightPage: _getPrevRightPage(),
        isFlipping: _isFlipping,
        isFlippingBackward: _isFlippingBackward,
        onFlipComplete: () {
          setState(() {
            _isFlipping = false;
            _isFlippingBackward = false;
          });
        },
      );
    }

    // From page 3 onwards: use existing logic (image left, text right)
    return PageFlipWidget(
      leftPage: ImagePageWidget(
        imagePath: currentPage.imagePath,
        pageNumber: currentPage.pageNumber,
        onReadAloud: () => _onReadAloud(currentPage),
      ),
      rightPage: TextPageWidget(
        text: currentPage.text,
        pageNumber: currentPage.pageNumber,
        level: widget.level,
        onWordTap: _onWordTap,
      ),
      nextLeftPage: _getNextLeftPage(),
      prevRightPage: _getPrevRightPage(),
      isFlipping: _isFlipping,
      isFlippingBackward: _isFlippingBackward,
      onFlipComplete: () {
        setState(() {
          _isFlipping = false;
          _isFlippingBackward = false;
        });
      },
    );
  }

  Widget _buildPageCurlNavigation() {
    return Stack(
      children: [
        // Previous page button (left corner)
        if (_currentPageIndex > 0)
          Positioned(
            left: 16,
            top: 16,
            child: _buildCornerNavigationButton(
              icon: Icons.chevron_left_rounded,
              onTap: _previousPage,
              isLeft: true,
            ),
          ),

        // Next page button (right corner)
        if (_currentPageIndex < widget.storybook.pages.length - 1)
          Positioned(
            right: 16,
            top: 16,
            child: _buildCornerNavigationButton(
              icon: Icons.chevron_right_rounded,
              onTap: _nextPage,
              isLeft: false,
            ),
          ),

        // Quiz button (when on last page)
        if (_isLastPage() && widget.storybook.quizGame != null)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: _startQuiz,
              backgroundColor: Colors.green[400],
              foregroundColor: Colors.white,
              icon: const Icon(Icons.quiz),
              label: const Text('Take Quiz'),
            ),
          ),
      ],
    );
  }

  Widget _buildCornerNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.grey[700],
          size: 24,
        ),
      ),
    );
  }

  bool _isLastPage() {
    return _currentPageIndex >= widget.storybook.pages.length - 1;
  }

  Widget? _getNextLeftPage() {
    // When next button is clicked, right page curls away
    // The next page's IMAGE should be revealed on the left side
    if (_currentPageIndex < widget.storybook.pages.length - 1) {
      final nextPage = widget.storybook.pages[_currentPageIndex + 1];
      return ImagePageWidget(
        imagePath: nextPage.imagePath,
        pageNumber: nextPage.pageNumber,
        onReadAloud: () => _onReadAloud(nextPage),
      );
    }
    return null;
  }

  Widget? _getPrevRightPage() {
    // When previous button is clicked, left page curls away
    // The previous page's TEXT should be revealed on the right side
    if (_currentPageIndex > 0) {
      final prevPage = widget.storybook.pages[_currentPageIndex - 1];
      return TextPageWidget(
        text: prevPage.text,
        pageNumber: prevPage.pageNumber,
        level: widget.level,
        onWordTap: _onWordTap,
      );
    }
    return null;
  }

  void _previousPage() {
    if (_currentPageIndex > 0 && !_isFlipping) {
      setState(() {
        _isFlipping = true;
        _isFlippingBackward = true; // Set backward direction
        // Special navigation logic for first spread
        if (_currentPageIndex == 2) {
          // From page 3, go back to page 1 (first spread)
          _currentPageIndex = 0;
        } else {
          // Normal navigation
          _currentPageIndex--;
        }
      });
      _pageFlipController.forward().then((_) {
        _pageFlipController.reset();
        setState(() {
          _isFlipping = false;
        });
      });
      HapticFeedback.lightImpact();
    }
  }

  void _nextPage() {
    if (_currentPageIndex < widget.storybook.pages.length - 1 && !_isFlipping) {
      setState(() {
        _isFlipping = true;
        _isFlippingBackward = false; // Set forward direction
        // Special navigation logic for first spread
        if (_currentPageIndex == 0) {
          // From page 1 (first spread), go to page 3
          _currentPageIndex = 2;
        } else {
          // Normal navigation
          _currentPageIndex++;
        }
      });
      _pageFlipController.forward().then((_) {
        _pageFlipController.reset();
        setState(() {
          _isFlipping = false;
        });
      });
      HapticFeedback.lightImpact();
    }
  }

  void _startQuiz() {
    if (widget.storybook.quizGame == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizGameScreen(
          quizGame: widget.storybook.quizGame!,
          storybookTitle: widget.storybook.title,
          storybookId: widget.storybook.id,
          levelId: widget.level,
          onComplete: () {
            Navigator.of(context).pop();
            // Mark quiz as completed
            widget.storybook.quizCompleted = true;
            // Show completion dialog
            _showCompletionDialog();
          },
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '🎉 Story Complete!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Congratulations! You have finished reading this story and completed the quiz!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Icon(
              Icons.star,
              size: 60,
              color: Colors.amber[600],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to level screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _onWordTap(String word) {
    playPhonicsSound(word);
    HapticFeedback.lightImpact();
  }

  void _onReadAloud(StoryPage page) {
    HapticFeedback.mediumImpact();
    debugPrint('🎙️ Reading aloud page ${page.pageNumber}: "${page.text}"');

    // Use TTS service to speak the page text with Australian voice
    TTSService.instance.speak(page.text);
  }

  void playPhonicsSound(String word) {
    debugPrint('Playing phonics sound for word: $word');
  }
}
