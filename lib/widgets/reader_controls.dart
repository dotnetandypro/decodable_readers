import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReaderControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool isLandscape;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final Function(int) onPageJump;

  const ReaderControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.isLandscape,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onPageJump,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Previous button
            _buildControlButton(
              icon: Icons.arrow_back_ios_rounded,
              onTap: currentPage > 0 ? onPreviousPage : null,
              isEnabled: currentPage > 0,
            ),
            
            const SizedBox(width: 16),
            
            // Progress indicator
            Expanded(
              child: _buildProgressIndicator(),
            ),
            
            const SizedBox(width: 16),
            
            // Next button
            _buildControlButton(
              icon: Icons.arrow_forward_ios_rounded,
              onTap: _canGoNext() ? onNextPage : null,
              isEnabled: _canGoNext(),
            ),
          ],
        ),
      ),
    );
  }

  bool _canGoNext() {
    if (isLandscape) {
      // In landscape mode, we can go next if there are more page pairs
      return (currentPage + 2) < totalPages;
    } else {
      // In portrait mode, we can go next if there are more individual pages
      return (currentPage + 1) < totalPages;
    }
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEnabled 
              ? AppTheme.primaryColor 
              : AppTheme.textSecondary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ] : null,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Page indicator text
        Text(
          _getPageText(),
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _getProgress(),
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            minHeight: 6,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Page dots indicator (for smaller page counts)
        if (totalPages <= 10) _buildPageDots(),
      ],
    );
  }

  String _getPageText() {
    if (isLandscape && (currentPage + 1) < totalPages) {
      return 'Pages ${currentPage + 1}-${currentPage + 2} of $totalPages';
    } else {
      return 'Page ${currentPage + 1} of $totalPages';
    }
  }

  double _getProgress() {
    return (currentPage + 1) / totalPages;
  }

  Widget _buildPageDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = isLandscape 
            ? (index >= currentPage && index <= currentPage + 1)
            : (index == currentPage);
        
        return GestureDetector(
          onTap: () => onPageJump(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 12 : 8,
            height: isActive ? 12 : 8,
            decoration: BoxDecoration(
              color: isActive 
                  ? AppTheme.primaryColor 
                  : AppTheme.textSecondary.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
