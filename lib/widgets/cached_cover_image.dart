import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/cover_image_cache_service.dart';

class CachedCoverImage extends StatefulWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? fallbackColor;

  const CachedCoverImage({
    Key? key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.fallbackColor,
  }) : super(key: key);

  @override
  State<CachedCoverImage> createState() => _CachedCoverImageState();
}

class _CachedCoverImageState extends State<CachedCoverImage> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CachedCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _imageBytes = null;
    });

    try {
      final bytes = await CoverImageCacheService.getCoverImage(widget.imagePath);
      
      if (!mounted) return;
      
      if (bytes != null) {
        setState(() {
          _imageBytes = bytes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading cover image ${widget.imagePath}: $e');
      
      if (!mounted) return;
      
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildPlaceholder();
    }

    if (_hasError || _imageBytes == null) {
      return _buildErrorWidget();
    }

    return Image.memory(
      _imageBytes!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Error displaying cover image: $error');
        return _buildErrorWidget();
      },
    );
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.fallbackColor?.withOpacity(0.1) ?? Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.fallbackColor ?? Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading...',
              style: TextStyle(
                color: widget.fallbackColor ?? Colors.grey[600],
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.fallbackColor?.withOpacity(0.1) ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: widget.fallbackColor?.withOpacity(0.2) ?? Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book_rounded,
                color: widget.fallbackColor ?? Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                'Book',
                style: TextStyle(
                  color: widget.fallbackColor ?? Colors.grey[600],
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension widget for preloading cover images
class CoverImagePreloader extends StatefulWidget {
  final List<String> imagePaths;
  final Widget child;
  final VoidCallback? onPreloadComplete;
  final bool showProgress;

  const CoverImagePreloader({
    Key? key,
    required this.imagePaths,
    required this.child,
    this.onPreloadComplete,
    this.showProgress = true,
  }) : super(key: key);

  @override
  State<CoverImagePreloader> createState() => _CoverImagePreloaderState();
}

class _CoverImagePreloaderState extends State<CoverImagePreloader> {
  bool _isPreloading = true;
  int _loadedCount = 0;

  @override
  void initState() {
    super.initState();
    _preloadImages();
  }

  Future<void> _preloadImages() async {
    try {
      await CoverImageCacheService.preloadLevelCoverImages(widget.imagePaths);
      
      if (mounted) {
        setState(() {
          _isPreloading = false;
          _loadedCount = widget.imagePaths.length;
        });
        
        widget.onPreloadComplete?.call();
      }
    } catch (e) {
      debugPrint('❌ Error preloading cover images: $e');
      
      if (mounted) {
        setState(() {
          _isPreloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isPreloading && widget.showProgress) {
      return Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Loading book covers...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.imagePaths.length} covers',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
