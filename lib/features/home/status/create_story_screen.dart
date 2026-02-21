import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'story_editor_screen.dart';

class CreateStoryScreen extends ConsumerStatefulWidget {
  final List<XFile> initialImages;

  const CreateStoryScreen({super.key, required this.initialImages});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateStoryScreenState();
}

class _CreateStoryScreenState extends ConsumerState<CreateStoryScreen> {
  late List<XFile> _images;
  bool _isCollage = true; // true = Collage, false = Solo

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.initialImages);
  }

  Future<void> _pickMoreImages() async {
    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile> newImages = await picker.pickMultiImage();
      if (newImages.isNotEmpty) {
        setState(() {
          _images.addAll(newImages);
        });
      }
    } catch (e) {
      debugPrint("Error picking more images: $e");
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Create Story',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              if (_images.isEmpty) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      StoryEditorScreen(images: _images, isCollage: _isCollage),
                ),
              );
            },
            child: const Text(
              'Next',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  _buildGrid(),
                  const SizedBox(height: 24),
                  _buildAddButton(isDark),
                ],
              ),
            ),
          ),
          _buildBottomBar(isDark),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _images.length,
      itemBuilder: (context, index) {
        final file = _images[index];
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(file.path),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Number Badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '\${index + 1}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Remove Button
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddButton(bool isDark) {
    return GestureDetector(
      onTap: _pickMoreImages,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        ),
        // Simple faux-dashed look by just using a regular outline but styled gently.
        // The dotted_decoration package is in pubspec, we can use it!
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              'Add',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: 32,
      ), // bottom padding for safe area
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        border: Border(
          top: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeToggleBtn(
              title: "Collage",
              icon: Icons.grid_view_rounded,
              isActive: _isCollage,
              onTap: () => setState(() => _isCollage = true),
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildModeToggleBtn(
              title: "Solo",
              icon: Icons.copy, // Or appropriate icon
              isActive: !_isCollage,
              onTap: () => setState(() => _isCollage = false),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggleBtn({
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    if (isActive) {
      // Use Gradient Button
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFF0066FF), Color(0xFFF15EC9)],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Outline Button
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isDark ? Colors.white70 : Colors.black54,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
