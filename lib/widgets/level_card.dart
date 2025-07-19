import 'package:flutter/material.dart';
import '../models/story_models.dart';
import '../theme/app_theme.dart';
import '../services/progress_service.dart';

class LevelCard extends StatefulWidget {
  final Level level;
  final VoidCallback onTap;

  const LevelCard({
    super.key,
    required this.level,
    required this.onTap,
  });

  @override
  State<LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<LevelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  /// Get device-specific font size scaling
  /// iPad gets larger fonts than iPhone for better readability
  double _getScaledFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isIPad = screenWidth >= 1024; // iPad detection threshold

    // iPad gets 1.4x larger fonts, iPhone uses base size
    return isIPad ? baseFontSize * 1.4 : baseFontSize;
  }

  /// Build level background image decoration
  DecorationImage? _buildLevelBackgroundImage() {
    // Construct image path from level ID
    final imagePath = 'assets/icons/level${widget.level.id}.png';

    try {
      return DecorationImage(
        image: AssetImage(imagePath),
        fit: BoxFit.cover,
        alignment: Alignment.center,
      );
    } catch (e) {
      // Return null if image not found, will use white background
      return null;
    }
  }

  /// Build fallback gradient for when image is not available
  LinearGradient _buildFallbackGradient(Color levelColor) {
    return LinearGradient(
      colors: [
        levelColor,
        levelColor.withOpacity(0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = AppTheme.getLevelColor(widget.level.id - 1);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: levelColor.withOpacity(0.2),
                    blurRadius: _isPressed ? 8 : 12,
                    offset: Offset(0, _isPressed ? 2 : 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    // Header with level number and progress
                    Container(
                      height: 60,
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
                            right: -20,
                            top: -20,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${widget.level.id}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            _getScaledFontSize(context, 18),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.level.title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                              _getScaledFontSize(context, 16),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${ProgressService.instance.getBooksCompletedForLevel(widget.level.id)}/${widget.level.storybooks.length}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize:
                                              _getScaledFontSize(context, 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content area
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          image: _buildLevelBackgroundImage(),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                                0.6), // Reduced opacity to show more background image
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.level.description,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: _getScaledFontSize(context, 14),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Phonics chips - with flexible height
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children:
                                          widget.level.phonicsSet.map((phonic) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: levelColor.withValues(
                                                alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            phonic,
                                            style: TextStyle(
                                              color: levelColor,
                                              fontSize: _getScaledFontSize(
                                                  context, 12),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Progress bar
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Progress',
                                          style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize:
                                                _getScaledFontSize(context, 12),
                                          ),
                                        ),
                                        Text(
                                          '${(ProgressService.instance.getLevelProgressPercentage(widget.level.id, widget.level.storybooks.length) * 100).toInt()}%',
                                          style: TextStyle(
                                            color: levelColor,
                                            fontSize:
                                                _getScaledFontSize(context, 12),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: ProgressService.instance
                                            .getLevelProgressPercentage(
                                                widget.level.id,
                                                widget.level.storybooks.length),
                                        backgroundColor:
                                            levelColor.withValues(alpha: 0.1),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                levelColor),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
