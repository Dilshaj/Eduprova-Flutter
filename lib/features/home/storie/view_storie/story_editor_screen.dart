import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'stories_provider.dart';

enum StoryLayout {
  single,
  // 2 Images
  vSplit2, hSplit2, diagonalL2, diagonalR2, circle2,
  // 3 Images
  vSplit3, hSplit3, oneTopTwoBottom3, oneBottomTwoTop3, oneLeftTwoRight3, oneRightTwoLeft3, staggered3,
  // 4 Images
  grid2x2_4, oneBigThreeSmall4, vSplit4, hSplit4, diamond4, focusCenter4,
}

class StoryEditorScreen extends ConsumerStatefulWidget {
  final List<XFile> images;
  final bool isCollage;

  const StoryEditorScreen({
    super.key,
    required this.images,
    required this.isCollage,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StoryEditorScreenState();
}

class _StoryEditorScreenState extends ConsumerState<StoryEditorScreen> {
  final List<Uint8List> _loadedImages = [];
  Uint8List? _imageData;
  bool _isLoading = true;
  bool _isLayoutMode = true;
  int _soloSelectedIndex = 0;
  StoryLayout _currentLayout = StoryLayout.single;

  @override
  void initState() {
    super.initState();
    _loadAllImages();
  }

  Future<void> _loadAllImages() async {
    try {
      for (var image in widget.images) {
        final bytes = await image.readAsBytes();
        _loadedImages.add(bytes);
      }
      
      if (_loadedImages.length > 1) {
        _isLayoutMode = true;
        // Default layout for collage
        _currentLayout = switch (_loadedImages.length) {
          2 => StoryLayout.vSplit2,
          3 => StoryLayout.oneTopTwoBottom3,
          4 => StoryLayout.grid2x2_4,
          _ => StoryLayout.single,
        };
        await _generateCollage();
      } else {
        _isLayoutMode = false;
        _imageData = _loadedImages.first;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading images: $e')),
        );
      }
    }
  }

  Future<void> _generateCollage() async {
    // Generate collage based on _currentLayout and _loadedImages
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    const width = 1080.0;
    const height = 1920.0;
    
    // Paint premium background gradient
    final gradient = ui.Gradient.linear(
      const ui.Offset(0, 0),
      const ui.Offset(width, height),
      [const Color(0xFF1A1A1A), const Color(0xFF0D0D0D)],
    );
    canvas.drawRect(
      const ui.Rect.fromLTWH(0, 0, width, height),
      ui.Paint()..shader = gradient,
    );

    // Helper to draw image in a rect with rounded corners
    Future<void> drawImageInRect(Uint8List bytes, ui.Rect rect, {double borderRadius = 16.0}) async {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      // Calculate fit
      double srcW = image.width.toDouble();
      double srcH = image.height.toDouble();
      double dstW = rect.width;
      double dstH = rect.height;
      
      double scale = math.max(dstW / srcW, dstH / srcH);
      double drawW = srcW * scale;
      double drawH = srcH * scale;
      double dx = rect.left + (dstW - drawW) / 2;
      double dy = rect.top + (dstH - drawH) / 2;

      canvas.save();
      // Rounded corners clip
      if (borderRadius > 0) {
        canvas.clipRRect(ui.RRect.fromRectAndRadius(rect, ui.Radius.circular(borderRadius)));
      } else {
        canvas.clipRect(rect);
      }
      
      canvas.drawImageRect(
        image,
        ui.Rect.fromLTWH(0, 0, srcW, srcH),
        ui.Rect.fromLTWH(dx, dy, drawW, drawH),
        ui.Paint()..filterQuality = ui.FilterQuality.high,
      );
      canvas.restore();
    }

    // Apply layout
    switch (_currentLayout) {
      case StoryLayout.single:
        if (_loadedImages.isNotEmpty) {
          await drawImageInRect(_loadedImages[0], const ui.Rect.fromLTWH(0, 0, width, height));
        }
        break;
      // 2 IMAGES
      case StoryLayout.vSplit2:
        if (_loadedImages.length >= 2) {
          await drawImageInRect(_loadedImages[0], const ui.Rect.fromLTWH(0, 0, width / 2 - 2, height));
          await drawImageInRect(_loadedImages[1], const ui.Rect.fromLTWH(width / 2 + 2, 0, width / 2 - 2, height));
        }
        break;
      case StoryLayout.hSplit2:
        if (_loadedImages.length >= 2) {
          await drawImageInRect(_loadedImages[0], const ui.Rect.fromLTWH(0, 0, width, height / 2 - 2));
          await drawImageInRect(_loadedImages[1], const ui.Rect.fromLTWH(0, height / 2 + 2, width, height / 2 - 2));
        }
        break;
      case StoryLayout.diagonalL2:
        if (_loadedImages.length >= 2) {
          await drawImageInRect(_loadedImages[0], const ui.Rect.fromLTWH(0, 0, width * 0.7, height * 0.7));
          await drawImageInRect(_loadedImages[1], const ui.Rect.fromLTWH(width * 0.3, height * 0.3, width * 0.7, height * 0.7));
        }
        break;
      case StoryLayout.diagonalR2:
        if (_loadedImages.length >= 2) {
          await drawImageInRect(_loadedImages[1], const ui.Rect.fromLTWH(0, 0, width * 0.7, height * 0.7));
          await drawImageInRect(_loadedImages[0], const ui.Rect.fromLTWH(width * 0.3, height * 0.3, width * 0.7, height * 0.7));
        }
        break;
      case StoryLayout.circle2:
        if (_loadedImages.length >= 2) {
          await drawImageInRect(_loadedImages[0], const ui.Rect.fromLTWH(20, height * 0.2, width - 40, height * 0.3), borderRadius: 30);
          await drawImageInRect(_loadedImages[1], const ui.Rect.fromLTWH(20, height * 0.52, width - 40, height * 0.3), borderRadius: 30);
        }
        break;

      // 3 IMAGES
      case StoryLayout.vSplit3:
        if (_loadedImages.length >= 3) {
          const w3 = (width - 24) / 3;
          await drawImageInRect(_loadedImages[0], const ui.Rect.fromLTWH(6, 40, w3, height - 80), borderRadius: 12);
          await drawImageInRect(_loadedImages[1], const ui.Rect.fromLTWH(w3 + 12, 40, w3, height - 80), borderRadius: 12);
          await drawImageInRect(_loadedImages[2], const ui.Rect.fromLTWH(w3 * 2 + 18, 40, w3, height - 80), borderRadius: 12);
        }
        break;
      case StoryLayout.hSplit3:
        if (_loadedImages.length >= 3) {
          const h3 = (height - 24) / 3;
          await drawImageInRect(_loadedImages[0], const ui.Rect.fromLTWH(40, 6, width - 80, h3), borderRadius: 12);
          await drawImageInRect(_loadedImages[1], const ui.Rect.fromLTWH(40, h3 + 12, width - 80, h3), borderRadius: 12);
          await drawImageInRect(_loadedImages[2], const ui.Rect.fromLTWH(40, h3 * 2 + 18, width - 80, h3), borderRadius: 12);
        }
        break;
      case StoryLayout.oneTopTwoBottom3:
        if (_loadedImages.length >= 3) {
          await drawImageInRect(_loadedImages[0], const ui.Rect.fromLTWH(8, 8, width - 16, height * 0.5 - 12), borderRadius: 20);
          await drawImageInRect(_loadedImages[1], const ui.Rect.fromLTWH(8, height * 0.5 + 4, width / 2 - 12, height * 0.5 - 12), borderRadius: 20);
          await drawImageInRect(_loadedImages[2], const ui.Rect.fromLTWH(width / 2 + 4, height * 0.5 + 4, width / 2 - 12, height * 0.5 - 12), borderRadius: 20);
        }
        break;
      case StoryLayout.oneBottomTwoTop3:
        if (_loadedImages.length >= 3) {
          await drawImageInRect(_loadedImages[0], const ui.Rect.fromLTWH(8, height * 0.5 + 4, width - 16, height * 0.5 - 12), borderRadius: 20);
          await drawImageInRect(_loadedImages[1], const ui.Rect.fromLTWH(8, 8, width / 2 - 12, height * 0.5 - 12), borderRadius: 20);
          await drawImageInRect(_loadedImages[2], const ui.Rect.fromLTWH(width / 2 + 4, 8, width / 2 - 12, height * 0.5 - 12), borderRadius: 20);
        }
        break;
      case StoryLayout.oneLeftTwoRight3:
        if (_loadedImages.length >= 3) {
          await drawImageInRect(_loadedImages[0], const ui.Rect.fromLTWH(8, 8, width * 0.5 - 12, height - 16), borderRadius: 20);
          await drawImageInRect(_loadedImages[1], const ui.Rect.fromLTWH(width * 0.5 + 4, 8, width * 0.5 - 12, height / 2 - 12), borderRadius: 20);
          await drawImageInRect(_loadedImages[2], const ui.Rect.fromLTWH(width * 0.5 + 4, height / 2 + 4, width * 0.5 - 12, height / 2 - 12), borderRadius: 20);
        }
        break;
      case StoryLayout.oneRightTwoLeft3:
        if (_loadedImages.length >= 3) {
          await drawImageInRect(_loadedImages[0], const ui.Rect.fromLTWH(width * 0.5 + 4, 8, width * 0.5 - 12, height - 16), borderRadius: 20);
          await drawImageInRect(_loadedImages[1], const ui.Rect.fromLTWH(8, 8, width * 0.5 - 12, height / 2 - 12), borderRadius: 20);
          await drawImageInRect(_loadedImages[2], const ui.Rect.fromLTWH(8, height / 2 + 4, width * 0.5 - 12, height / 2 - 12), borderRadius: 20);
        }
        break;
      case StoryLayout.staggered3:
        if (_loadedImages.length >= 3) {
          await drawImageInRect(_loadedImages[0], const ui.Rect.fromLTWH(20, 100, width * 0.6, height * 0.35), borderRadius: 24);
          await drawImageInRect(_loadedImages[1], const ui.Rect.fromLTWH(width * 0.35, height * 0.35, width * 0.6, height * 0.35), borderRadius: 24);
          await drawImageInRect(_loadedImages[2], const ui.Rect.fromLTWH(20, height * 0.6, width * 0.6, height * 0.35), borderRadius: 24);
        }
        break;

      // 4 IMAGES
      case StoryLayout.grid2x2_4:
        if (_loadedImages.length >= 4) {
          await drawImageInRect(_loadedImages[0], const ui.Rect.fromLTWH(8, 8, width / 2 - 12, height / 2 - 12), borderRadius: 20);
          await drawImageInRect(_loadedImages[1], const ui.Rect.fromLTWH(width / 2 + 4, 8, width / 2 - 12, height / 2 - 12), borderRadius: 20);
          await drawImageInRect(_loadedImages[2], const ui.Rect.fromLTWH(8, height / 2 + 4, width / 2 - 12, height / 2 - 12), borderRadius: 20);
          await drawImageInRect(_loadedImages[3], const ui.Rect.fromLTWH(width / 2 + 4, height / 2 + 4, width / 2 - 12, height / 2 - 12), borderRadius: 20);
        }
        break;
      case StoryLayout.oneBigThreeSmall4:
        if (_loadedImages.length >= 4) {
          await drawImageInRect(_loadedImages[0], const ui.Rect.fromLTWH(8, 8, width - 16, height * 0.6 - 12), borderRadius: 24);
          const w3 = (width - 24) / 3;
          await drawImageInRect(_loadedImages[1], const ui.Rect.fromLTWH(8, height * 0.6 + 4, w3, height * 0.4 - 12), borderRadius: 12);
          await drawImageInRect(_loadedImages[2], const ui.Rect.fromLTWH(w3 + 12, height * 0.6 + 4, w3, height * 0.4 - 12), borderRadius: 12);
          await drawImageInRect(_loadedImages[3], const ui.Rect.fromLTWH(w3 * 2 + 16, height * 0.6 + 4, w3, height * 0.4 - 12), borderRadius: 12);
        }
        break;
      case StoryLayout.vSplit4:
        if (_loadedImages.length >= 4) {
          const w4 = (width - 30) / 4;
          await drawImageInRect(_loadedImages[0], const ui.Rect.fromLTWH(6, 40, w4, height - 80), borderRadius: 10);
          await drawImageInRect(_loadedImages[1], const ui.Rect.fromLTWH(w4 + 12, 40, w4, height - 80), borderRadius: 10);
          await drawImageInRect(_loadedImages[2], const ui.Rect.fromLTWH(w4 * 2 + 18, 40, w4, height - 80), borderRadius: 10);
          await drawImageInRect(_loadedImages[3], const ui.Rect.fromLTWH(w4 * 3 + 24, 40, w4, height - 80), borderRadius: 10);
        }
        break;
      case StoryLayout.hSplit4:
        if (_loadedImages.length >= 4) {
          const h4 = (height - 30) / 4;
          await drawImageInRect(_loadedImages[0], const ui.Rect.fromLTWH(40, 6, width - 80, h4), borderRadius: 10);
          await drawImageInRect(_loadedImages[1], const ui.Rect.fromLTWH(40, h4 + 12, width - 80, h4), borderRadius: 10);
          await drawImageInRect(_loadedImages[2], const ui.Rect.fromLTWH(40, h4 * 2 + 18, width - 80, h4), borderRadius: 10);
          await drawImageInRect(_loadedImages[3], const ui.Rect.fromLTWH(40, h4 * 3 + 24, width - 80, h4), borderRadius: 10);
        }
        break;
      case StoryLayout.diamond4:
        if (_loadedImages.length >= 4) {
          await drawImageInRect(_loadedImages[0], const ui.Rect.fromLTWH(width * 0.2, 100, width * 0.6, height * 0.2), borderRadius: 100);
          await drawImageInRect(_loadedImages[1], const ui.Rect.fromLTWH(20, height * 0.35, width * 0.45, height * 0.3), borderRadius: 100);
          await drawImageInRect(_loadedImages[2], const ui.Rect.fromLTWH(width * 0.53, height * 0.35, width * 0.45, height * 0.3), borderRadius: 100);
          await drawImageInRect(_loadedImages[3], const ui.Rect.fromLTWH(width * 0.2, height * 0.7, width * 0.6, height * 0.2), borderRadius: 100);
        }
        break;
      case StoryLayout.focusCenter4:
        if (_loadedImages.length >= 4) {
          await drawImageInRect(_loadedImages[0], const ui.Rect.fromLTWH(10, 10, width / 2 - 15, height / 2 - 15), borderRadius: 20);
          await drawImageInRect(_loadedImages[1], const ui.Rect.fromLTWH(width / 2 + 5, 10, width / 2 - 15, height / 2 - 15), borderRadius: 20);
          await drawImageInRect(_loadedImages[2], const ui.Rect.fromLTWH(10, height / 2 + 5, width / 2 - 15, height / 2 - 15), borderRadius: 20);
          await drawImageInRect(_loadedImages[3], const ui.Rect.fromLTWH(width * 0.15, height * 0.3, width * 0.7, height * 0.4), borderRadius: 40);
        }
        break;
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    _imageData = byteData!.buffer.asUint8List();
  }

  Future<void> _toggleMode(bool isLayout) async {
    if (_isLayoutMode == isLayout) return;

    setState(() {
      _isLoading = true;
      _isLayoutMode = isLayout;
    });

    if (isLayout) {
      await _generateCollage();
    } else {
      _imageData = _loadedImages[_soloSelectedIndex];
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectSoloImage(int index) async {
    if (_soloSelectedIndex == index) return;

    setState(() {
      _isLoading = true;
      _soloSelectedIndex = index;
      _imageData = _loadedImages[index];
    });

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const Scaffold(body: Center(child: Text("No images selected")));
    }

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_imageData == null && _isLayoutMode) {
      return const Scaffold(body: Center(child: Text("Failed to load layout data")));
    }

    return Theme(
      data: Theme.of(context).copyWith(
        scrollbarTheme: ScrollbarThemeData(
          thumbVisibility: WidgetStateProperty.all(false),
          trackVisibility: WidgetStateProperty.all(false),
          thickness: WidgetStateProperty.all(0),
        ),
      ),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Scaffold(
          body: _isLayoutMode 
            ? ProImageEditor.memory(
                _imageData!,
                key: ValueKey('layout_${_currentLayout.name}'),
                callbacks: _buildEditorCallbacks(),
                configs: _buildEditorConfigs(),
              )
            : PageView.builder(
                itemCount: _loadedImages.length,
                onPageChanged: (index) {
                  setState(() {
                    _soloSelectedIndex = index;
                  });
                },
                controller: PageController(initialPage: _soloSelectedIndex),
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ProImageEditor.memory(
                    _loadedImages[index],
                    key: ValueKey('solo_$index'),
                    callbacks: _buildEditorCallbacks(),
                    configs: _buildEditorConfigs(),
                  );
                },
              ),
        ),
      ),
    );
  }

  AppBar _buildCustomTopBar(ProImageEditorState editor) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
      actions: [
        _buildTopAction(
          icon: Icons.undo,
          onTap: editor.canUndo ? () => editor.undoAction() : null,
        ),
        _buildTopAction(
          icon: Icons.redo,
          onTap: editor.canRedo ? () => editor.redoAction() : null,
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.check, color: Colors.white),
          onPressed: editor.doneEditing,
        ),
      ],
    );
  }

  Widget _buildTopAction({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return IconButton(
      icon: Icon(icon, color: onTap == null ? Colors.white24 : Colors.white),
      onPressed: onTap,
    );
  }

  Widget _buildCustomBottomBar(ProImageEditorState editor, Key key) {
    return ClipRRect(
      key: key,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            border: const Border(top: BorderSide(color: Colors.white10)),
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Crop Button
                IconButton(
                  icon: const Icon(Icons.crop),
                  onPressed: editor.openCropRotateEditor,
                ),
                // Plus Button (Add Image Layer)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      final bytes = await image.readAsBytes();
                      editor.addLayer(
                        WidgetLayer(
                          offset: Offset.zero,
                          scale: 1.0,
                          widget: Image.memory(
                            bytes,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }
                  },
                ),
                const Spacer(),
                // Layout Button (only show if collage mode)
                if (_loadedImages.length > 1) ...[
                  _buildModeToggleButton(
                    label: 'Solo',
                    isSelected: !_isLayoutMode,
                    onTap: () => _toggleMode(false),
                  ),
                  const SizedBox(width: 8),
                  _buildModeToggleButton(
                    label: 'Layout',
                    isSelected: _isLayoutMode,
                    onTap: () => _toggleMode(true),
                  ),
                  const SizedBox(width: 8),
                ],
                if (_isLayoutMode && _loadedImages.length > 1)
                  IconButton(
                    onPressed: () => _showLayoutPicker(),
                    icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
                    tooltip: 'Change Layout',
                  ),
                // Add Story Button
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0066FF), Color(0xFFF15EC9)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ElevatedButton(
                    onPressed: editor.doneEditing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text(
                      'Add Story',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
  }

  Widget _buildModeToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSoloThumbnailList() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _loadedImages.length,
        itemBuilder: (context, index) {
          final isSelected = _soloSelectedIndex == index;
          return GestureDetector(
            onTap: () => _selectSoloImage(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.white24,
                  width: 2,
                ),
                image: DecorationImage(
                  image: MemoryImage(_loadedImages[index]),
                  fit: BoxFit.cover,
                ),
              ),
              child: isSelected
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 20),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  void _showLayoutPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Choose Layout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (_loadedImages.length == 2) ...[
                          _buildLayoutOption('Split V', Icons.view_column_outlined, StoryLayout.vSplit2),
                          _buildLayoutOption('Split H', Icons.view_stream_outlined, StoryLayout.hSplit2),
                          _buildLayoutOption('Diagonal L', Icons.view_quilt_rounded, StoryLayout.diagonalL2),
                          _buildLayoutOption('Diagonal R', Icons.view_quilt_sharp, StoryLayout.diagonalR2),
                        ],
                        if (_loadedImages.length == 3) ...[
                          _buildLayoutOption('Top Big', Icons.view_agenda_outlined, StoryLayout.oneTopTwoBottom3),
                          _buildLayoutOption('Bottom Big', Icons.view_agenda_rounded, StoryLayout.oneBottomTwoTop3),
                          _buildLayoutOption('Left Big', Icons.view_quilt_rounded, StoryLayout.oneLeftTwoRight3),
                          _buildLayoutOption('Right Big', Icons.view_quilt_sharp, StoryLayout.oneRightTwoLeft3),
                          _buildLayoutOption('Staggered', Icons.dashboard_customize_outlined, StoryLayout.staggered3),
                          _buildLayoutOption('3 Columns', Icons.view_column_rounded, StoryLayout.vSplit3),
                          _buildLayoutOption('3 Rows', Icons.view_stream_rounded, StoryLayout.hSplit3),
                        ],
                        if (_loadedImages.length == 4) ...[
                          _buildLayoutOption('Grid 2x2', Icons.grid_view_rounded, StoryLayout.grid2x2_4),
                          _buildLayoutOption('Big Top Left', Icons.view_quilt_outlined, StoryLayout.oneBigThreeSmall4),
                          _buildLayoutOption('Center Focus', Icons.center_focus_weak_rounded, StoryLayout.focusCenter4),
                          _buildLayoutOption('Diamond', Icons.diamond_outlined, StoryLayout.diamond4),
                          _buildLayoutOption('4 Columns', Icons.view_column_outlined, StoryLayout.vSplit4),
                          _buildLayoutOption('4 Rows', Icons.view_stream_outlined, StoryLayout.hSplit4),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLayoutOption(String label, IconData icon, StoryLayout layout) {
    final isSelected = _currentLayout == layout;
    return GestureDetector(
      onTap: () async {
        setState(() {
          _isLoading = true;
          _currentLayout = layout;
        });
        Navigator.pop(context);
        await _generateCollage();
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: Container(
        width: 85,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.white10,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.white,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  ProImageEditorCallbacks _buildEditorCallbacks() {
    return ProImageEditorCallbacks(
      onImageEditingComplete: (bytes) async {
        try {
          // Show loading
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );

          if (_isLayoutMode) {
            await ref.read(statusProfilesProvider.notifier).createStory([bytes], isCollage: true);
          } else {
            await ref.read(statusProfilesProvider.notifier).createStory(_loadedImages, isCollage: false);
          }

          if (mounted) {
            Navigator.of(context).pop(); // Close loader
            Navigator.of(context).pop(); // Close editor
            Navigator.of(context).pop(); // Close selection screen
          }
        } catch (e) {
          if (mounted) {
            Navigator.of(context).pop(); // Close loader
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload story: $e')),
            );
          }
        }
      },
    );
  }

  ProImageEditorConfigs _buildEditorConfigs() {
    return ProImageEditorConfigs(
      designMode: ImageEditorDesignMode.material,
      paintEditor: const PaintEditorConfigs(enableZoom: true),
      mainEditor: MainEditorConfigs(
        enableZoom: true,
        widgets: MainEditorWidgets(
          appBar: (editor, rebuildStream) => ReactiveAppbar(
            builder: (context) {
              return _buildCustomTopBar(editor);
            },
            stream: rebuildStream,
          ),
          wrapBody: (editor, rebuildStream, content) {
            return ReactiveWidget(
              stream: rebuildStream,
              builder: (_) => Stack(
                children: [
                  content,
                  if (!editor.isSubEditorOpen) ...[
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + 20,
                      right: 16,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 0.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.auto_awesome,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => _showEffectsSheet(editor),
                                  tooltip: 'Filters & Adjust',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  onPressed: editor.openPaintEditor, // Doodle
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.text_fields,
                                    color: Colors.white,
                                  ),
                                  onPressed: editor.openTextEditor, // Text
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.sentiment_satisfied_alt,
                                    color: Colors.white,
                                  ),
                                  onPressed: editor.openEmojiEditor, // Emoji
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          bottomBar: (editor, rebuildStream, key) {
            return ReactiveWidget(
              stream: rebuildStream,
              builder: (_) {
                if (editor.isSubEditorOpen) {
                  return SizedBox.shrink(key: key);
                }
                return Stack(
                  children: [
                    _buildCustomBottomBar(editor, key),
                    if (!_isLayoutMode && _loadedImages.length > 1)
                      Positioned(
                        bottom: 100,
                        left: 0,
                        right: 0,
                        child: _buildSoloThumbnailList(),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showEffectsSheet(ProImageEditorState editor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Filters & Adjustments',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildEffectOption(
                  icon: Icons.auto_awesome,
                  title: 'Filters',
                  subtitle: 'Apply preset color effects',
                  onTap: () {
                    Navigator.pop(context);
                    editor.openFilterEditor();
                  },
                ),
                const SizedBox(height: 16),
                _buildEffectOption(
                  icon: Icons.tune,
                  title: 'Adjustments',
                  subtitle: 'Contrast, Brightness, Saturation',
                  onTap: () {
                    Navigator.pop(context);
                    editor.openTuneEditor();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEffectOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
