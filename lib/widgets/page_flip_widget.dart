import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import '../services/settings_service.dart';
import '../services/word_audio_service.dart';
import 'cached_story_image.dart';

// New widget for text page with background
class TextPageWidget extends StatefulWidget {
  final String text;
  final int pageNumber;
  final int level;
  final Function(String)? onWordTap;

  const TextPageWidget({
    super.key,
    required this.text,
    required this.pageNumber,
    required this.level,
    this.onWordTap,
  });

  @override
  State<TextPageWidget> createState() => _TextPageWidgetState();
}

class _TextPageWidgetState extends State<TextPageWidget> {
  int? _highlightedWordIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/text_cover.png',
                fit: BoxFit.cover,
              ),
            ),

            // Text content with minimal padding for maximum text space
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15, // Minimal horizontal padding for thin borders
                vertical: 25, // Reduced vertical padding for more text space
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, // Minimal additional horizontal padding
                      vertical: 20, // Reduced additional vertical padding
                    ),
                    child: _buildTappableText(widget.text),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTappableText(String text) {
    final words = text.split(' ');
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = SettingsService.instance
        .getFontSizeForLevel(widget.level, screenWidth: screenWidth);

    // Make spacing proportional to font size
    // Extremely small ratio for extremely tight gaps
    const spacingRatio = 0.02;
    final wordSpacing = fontSize * spacingRatio;
    final lineSpacing = fontSize * spacingRatio;

    return Wrap(
      spacing: wordSpacing,
      runSpacing: lineSpacing,
      alignment: WrapAlignment.center,
      children: words.asMap().entries.map((entry) {
        final wordIndex = entry.key;
        final word = entry.value;
        final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '');
        final isHighlighted = _highlightedWordIndex == wordIndex;

        return GestureDetector(
          onTap: () {
            setState(() {
              _highlightedWordIndex = wordIndex;
            });

            // Play word audio
            WordAudioService.instance.playWord(cleanWord);

            // Haptic feedback
            HapticFeedback.lightImpact();

            widget.onWordTap?.call(cleanWord);

            // Clear highlight after 1 second
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (mounted) {
                setState(() {
                  _highlightedWordIndex = null;
                });
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? Colors.yellow.withValues(alpha: 0.6)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              word,
              textScaler: TextScaler.noScaling, // Disable system text scaling
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.brown[800],
                height: 1.5,
                fontFamily: 'Fredoka',
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// New widget for image-only page in horizontal mode
class ImagePageWidget extends StatelessWidget {
  final String imagePath;
  final int pageNumber;
  final VoidCallback? onReadAloud;

  const ImagePageWidget({
    super.key,
    required this.imagePath,
    required this.pageNumber,
    this.onReadAloud,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Full image - fill entire box like text_cover.png
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: CachedStoryImage(
                  imagePath: imagePath,
                  fit: BoxFit.cover, // Fill entire box like text_cover.png
                ),
              ),
            ),

            // Page number at middle bottom (only for left pages)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$pageNumber',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Read aloud button in right corner
            if (onReadAloud != null)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: onReadAloud,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange[400],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PageFlipWidget extends StatefulWidget {
  final Widget leftPage;
  final Widget rightPage;
  final Widget? nextLeftPage; // Page that will become left after next flip
  final Widget?
      prevRightPage; // Page that will become right after previous flip
  final VoidCallback? onFlipComplete;
  final bool isFlipping;
  final bool isFlippingBackward;

  const PageFlipWidget({
    super.key,
    required this.leftPage,
    required this.rightPage,
    this.nextLeftPage,
    this.prevRightPage,
    this.onFlipComplete,
    this.isFlipping = false,
    this.isFlippingBackward = false,
  });

  @override
  State<PageFlipWidget> createState() => _PageFlipWidgetState();
}

class _PageFlipWidgetState extends State<PageFlipWidget>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _curlAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Slide animation (0.0 to 1.0) - smooth slide motion
    _curlAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOutCubic, // Smooth slide curve
    ));

    // Shadow intensity animation
    _shadowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));

    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFlipComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(PageFlipWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipping && !oldWidget.isFlipping) {
      _flipController.forward();
    } else if (!widget.isFlipping && oldWidget.isFlipping) {
      _flipController.reverse();
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flipController,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Calculate square dimensions based on available space
            final availableWidth = constraints.maxWidth;
            final availableHeight = constraints.maxHeight;

            // Make pages square - use the smaller dimension
            final pageSize =
                math.min(availableWidth / 2.2, availableHeight * 0.9);
            final totalWidth = pageSize * 2 + 16; // Two pages + spine

            return Center(
              child: Container(
                width: totalWidth,
                height: pageSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 25,
                      offset: const Offset(0, 15),
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Base book layout with square pages
                      Row(
                        children: [
                          // Left square page
                          Container(
                            width: pageSize,
                            height: pageSize,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                            ),
                            child: widget.leftPage,
                          ),

                          // Book spine
                          Container(
                            width: 16,
                            height: pageSize,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.brown[300]!,
                                  Colors.brown[600]!,
                                  Colors.brown[800]!,
                                  Colors.brown[600]!,
                                  Colors.brown[300]!,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                          ),

                          // Right square page
                          Container(
                            width: pageSize,
                            height: pageSize,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: widget.rightPage,
                          ),
                        ],
                      ),

                      // Animated flipping page overlay
                      if (widget.isFlipping) _buildFlippingPage(pageSize),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFlippingPage(double pageSize) {
    final pageWidth = pageSize; // Use the calculated square page size

    // Calculate slide animation progress
    final slideProgress = _curlAnimation.value;
    final shadowIntensity = _shadowAnimation.value;

    // Determine slide direction and distance
    final isNext = !widget.isFlippingBackward;
    final slideDistance = pageWidth * 1.2; // Slide distance beyond screen

    // Calculate slide offset
    double slideOffset;
    if (isNext) {
      // Next: slide from right to left (starts at +slideDistance, ends at 0)
      slideOffset = slideDistance * (1.0 - slideProgress);
    } else {
      // Previous: slide from left to right (starts at -slideDistance, ends at 0)
      slideOffset = -slideDistance * (1.0 - slideProgress);
    }

    return Positioned(
      left: slideOffset,
      top: 0,
      width: pageWidth * 2 + 16, // Full book width (both pages + spine)
      height: pageSize,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: shadowIntensity * 0.4),
              blurRadius: 20 * shadowIntensity,
              offset: Offset(
                isNext ? -10 * shadowIntensity : 10 * shadowIntensity,
                8 * shadowIntensity,
              ),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: shadowIntensity * 0.2),
              blurRadius: 30 * shadowIntensity,
              offset: Offset(
                isNext ? -15 * shadowIntensity : 15 * shadowIntensity,
                12 * shadowIntensity,
              ),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              // Left page of the sliding book
              Container(
                width: pageSize,
                height: pageSize,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: widget.isFlippingBackward
                    ? (widget.prevRightPage ??
                        Container(
                          color: Colors.white,
                          child: const Center(
                            child: Text(
                              'Previous Page',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ))
                    : widget.leftPage,
              ),

              // Book spine
              Container(
                width: 16,
                height: pageSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.brown[300]!,
                      Colors.brown[600]!,
                      Colors.brown[800]!,
                      Colors.brown[600]!,
                      Colors.brown[300]!,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Right page of the sliding book
              Container(
                width: pageSize,
                height: pageSize,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: widget.isFlippingBackward
                    ? widget.rightPage
                    : (widget.nextLeftPage ??
                        Container(
                          color: Colors.white,
                          child: const Center(
                            child: Text(
                              'Next Page',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookPageWidget extends StatelessWidget {
  final String imagePath;
  final String text;
  final int pageNumber;
  final int level;
  final VoidCallback? onReadAloud;
  final Function(String)? onWordTap;

  const BookPageWidget({
    super.key,
    required this.imagePath,
    required this.text,
    required this.pageNumber,
    required this.level,
    this.onReadAloud,
    this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image area - Perfect square, takes most space
          Expanded(
            flex: isLandscape
                ? 9
                : 8, // More space in landscape for larger images
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(
                  12, 0, 12, 0), // Stick to top, no bottom gap
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Make it a perfect square based on the smaller dimension
                  final size = constraints.maxWidth < constraints.maxHeight
                      ? constraints.maxWidth
                      : constraints.maxHeight;

                  return Center(
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: Colors.white, // White background for full square
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            // Full image without cropping
                            Positioned.fill(
                              child: Container(
                                color: Colors.white,
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit
                                      .cover, // Fill entire box like text_cover.png
                                  width: double.infinity,
                                  height: double.infinity,
                                  frameBuilder: (context, child, frame,
                                      wasSynchronouslyLoaded) {
                                    if (wasSynchronouslyLoaded) {
                                      return child;
                                    }
                                    return AnimatedOpacity(
                                      opacity: frame == null ? 0 : 1,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: frame == null
                                          ? Container(
                                              color: Colors.grey[100],
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    Colors.orange[400]!,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : child,
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons
                                                  .image_not_supported_outlined,
                                              size: 40,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Image not found',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Page number in left corner
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Page $pageNumber',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            // Read aloud button in right corner
                            if (onReadAloud != null)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: GestureDetector(
                                  onTap: onReadAloud,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[400],
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange
                                              .withValues(alpha: 0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.volume_up_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),

                            // Speech bubble for page 1 instruction
                            if (pageNumber == 1)
                              Positioned(
                                bottom: 20,
                                left: 20,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[400],
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.blue.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.touch_app,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Tap words to hear sounds!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Fredoka',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Text area below - Takes remaining space
          Expanded(
            flex: isLandscape
                ? 1
                : 2, // Less space in landscape for larger images
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(
                  12, 0, 12, 0), // Stick to image, no gaps
              padding:
                  const EdgeInsets.all(16), // Less padding for more text room
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.brown[200]!, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: _buildTappableText(context, text),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTappableText(BuildContext context, String text) {
    final words = text.split(' ');
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = SettingsService.instance
        .getFontSizeForLevel(level, screenWidth: screenWidth);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: words.map((word) {
        final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '');

        return GestureDetector(
          onTap: () {
            // Play word audio
            WordAudioService.instance.playWord(cleanWord);

            // Haptic feedback
            HapticFeedback.lightImpact();

            onWordTap?.call(cleanWord);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.transparent, width: 2),
            ),
            child: Text(
              word,
              textScaler: TextScaler.noScaling, // Disable system text scaling
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.brown[800],
                height: 1.5,
                fontFamily: 'Fredoka', // Educational font
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
