import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/utils/image_cache_manager.dart';

class ImagePreviewScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String heroTag;

  const ImagePreviewScreen({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.heroTag = '',
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          final imageUrl = widget.imageUrls[index];
          final isInitial = index == widget.initialIndex;

          Widget imageWidget = InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: imageUrl.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    cacheManager: CacheManagers.messageCacheManager,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, color: Colors.white, size: 50),
                  )
                : Image.file(
                    File(imageUrl),
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error, color: Colors.white, size: 50),
                  ),
          );

          if (isInitial && widget.heroTag.isNotEmpty) {
            imageWidget = Hero(tag: widget.heroTag, child: imageWidget);
          }

          return Center(child: imageWidget);
        },
      ),
    );
  }
}
