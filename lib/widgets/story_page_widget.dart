import 'package:flutter/material.dart';
import '../models/story_models.dart';
import '../theme/app_theme.dart';

class StoryPageWidget extends StatefulWidget {
  final StoryPage page;
  final Function(String) onWordTap;
  final VoidCallback onReadAloud;

  const StoryPageWidget({
    super.key,
    required this.page,
    required this.onWordTap,
    required this.onReadAloud,
  });

  @override
  State<StoryPageWidget> createState() => _StoryPageWidgetState();
}

class _StoryPageWidgetState extends State<StoryPageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  String? _tappedWord;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  // Image section
                  Expanded(
                    flex: 3,
                    child: _buildImageSection(),
                  ),
                  
                  // Text section
                  Expanded(
                    flex: 2,
                    child: _buildTextSection(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.secondaryColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Placeholder for story image
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.image_rounded,
                color: AppTheme.primaryColor,
                size: 60,
              ),
            ),
          ),
          
          // Page number indicator
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Page ${widget.page.pageNumber}',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          // Read aloud button
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: widget.onReadAloud,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tappable text
          _buildTappableText(),
          
          const SizedBox(height: 16),
          
          // Read aloud button (alternative placement)
          ElevatedButton.icon(
            onPressed: widget.onReadAloud,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Read Out Loud'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTappableText() {
    final words = widget.page.text.split(' ');
    
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: words.map((word) {
        // Clean the word of punctuation for the tap handler
        final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '');
        final isHighlighted = _tappedWord == cleanWord;
        
        return GestureDetector(
          onTap: () => _onWordTapped(cleanWord),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isHighlighted 
                  ? AppTheme.accentColor.withOpacity(0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isHighlighted 
                    ? AppTheme.accentColor
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              word,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isHighlighted 
                    ? AppTheme.textPrimary
                    : AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _onWordTapped(String word) {
    setState(() {
      _tappedWord = word;
    });
    
    // Call the word tap handler
    widget.onWordTap(word);
    
    // Clear the highlight after a delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _tappedWord = null;
        });
      }
    });
  }
}
