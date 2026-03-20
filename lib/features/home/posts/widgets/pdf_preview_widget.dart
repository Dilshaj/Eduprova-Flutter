import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import 'package:shimmer/shimmer.dart';
import 'package:eduprova/theme/theme.dart';
import 'package:eduprova/core/utils/image_cache_manager.dart';
import 'package:hugeicons/hugeicons.dart';

class PdfPreviewWidget extends StatefulWidget {
  final String pdfUrl;

  const PdfPreviewWidget({super.key, required this.pdfUrl});

  @override
  State<PdfPreviewWidget> createState() => _PdfPreviewWidgetState();
}

class _PdfPreviewWidgetState extends State<PdfPreviewWidget> {
  PdfDocument? _document;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  double _pageAspectRatio = 1.0;
  PageController? _pageController;
  double _currentViewportFraction = 0.9;
  final Map<int, MemoryImage> _imageCache = {};

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final fileInfo = await CacheManagers.postCacheManager.downloadFile(
        widget.pdfUrl,
      );
      _document = await PdfDocument.openFile(fileInfo.file.path);
      if (_document!.pagesCount > 0) {
        final firstPage = await _document!.getPage(1);
        _pageAspectRatio = firstPage.width / firstPage.height;
        await firstPage.close();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _document?.close();
    _pageController?.dispose();
    for (final image in _imageCache.values) {
      image.evict();
    }
    super.dispose();
  }

  void _initPageController(double fraction) {
    if (_pageController == null || _currentViewportFraction != fraction) {
      final int initialPage = _currentPage > 0 ? _currentPage - 1 : 0;
      _pageController?.dispose();
      _currentViewportFraction = fraction;
      _pageController = PageController(
        viewportFraction: fraction,
        initialPage: initialPage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;

    if (_isLoading) {
      return SizedBox(
        height: 400,
        child: Shimmer.fromColors(
          baseColor: themeExt.cardColor,
          highlightColor: theme.dividerColor,
          child: Container(
            margin: const .symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: .circular(12),
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null || _document == null) {
      return SizedBox(
        height: 400,
        child: Center(
          child: Padding(
            padding: const .symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: .min,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedAlert01,
                  color: theme.colorScheme.error,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  'Failed to load PDF: ${_errorMessage ?? "Unknown error"}',
                  textAlign: .center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final availableWidth =
        screenWidth - 32; // Assuming 16 padding on each side for Post card
    final double maxItemWidth = availableWidth * 0.9;

    double targetHeight = 400.0;
    double itemWidth = targetHeight * _pageAspectRatio;

    if (itemWidth > maxItemWidth) {
      itemWidth = maxItemWidth;
      targetHeight = itemWidth / _pageAspectRatio;
    }

    final fraction = itemWidth / availableWidth;
    final viewportFraction = fraction.clamp(0.1, 1.0);
    _initPageController(viewportFraction);

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        SizedBox(
          height: targetHeight,
          child: PageView.builder(
            itemCount: _document!.pagesCount,
            controller: _pageController,
            padEnds: _document!.pagesCount == 1,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index + 1;
              });
            },
            itemBuilder: (context, index) {
              final cachedImage = _imageCache[index];

              return FutureBuilder<MemoryImage?>(
                future: _renderPage(index),
                builder: (context, snapshot) {
                  final image = snapshot.data ?? cachedImage;

                  if (snapshot.connectionState == ConnectionState.waiting &&
                      image == null) {
                    return Shimmer.fromColors(
                      baseColor: themeExt.cardColor,
                      highlightColor: theme.dividerColor,
                      child: Container(
                        margin: const .symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: .circular(12),
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError || image == null) {
                    return Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedImage01,
                        color: theme.iconTheme.color ?? Colors.grey,
                        size: 40,
                      ),
                    );
                  }

                  return Padding(
                    padding: const .symmetric(horizontal: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: .circular(12),
                        border: Border.all(color: theme.dividerColor, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: .circular(11),
                        child: Image(image: image, fit: BoxFit.contain),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const .symmetric(horizontal: 16),
          child: Text(
            '$_currentPage / ${_document!.pagesCount} pages',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.hintColor,
            ),
          ),
        ),
      ],
    );
  }

  Future<MemoryImage?> _renderPage(int index) async {
    if (_imageCache.containsKey(index)) {
      return _imageCache[index];
    }

    final page = await _document!.getPage(index + 1);

    final image = await page.render(
      width: page.width * 2,
      height: page.height * 2,
      format: PdfPageImageFormat.png,
    );

    await page.close();

    if (image?.bytes != null) {
      _imageCache[index] = MemoryImage(image!.bytes);
      return _imageCache[index];
    }
    return null;
  }
}
