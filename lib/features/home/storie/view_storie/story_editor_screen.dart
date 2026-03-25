import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'stories_provider.dart';

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
  final int _currentSoloIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const Scaffold(body: Center(child: Text("No images selected")));
    }

    return Scaffold(
      body: ProImageEditor.file(
        File(widget.images[_currentSoloIndex].path),
        callbacks: ProImageEditorCallbacks(
          onImageEditingComplete: (bytes) async {
            try {
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );

              // Save to temp file
              final tempDir = Directory.systemTemp;
              final file = File('${tempDir.path}/story_${DateTime.now().millisecondsSinceEpoch}.png');
              await file.writeAsBytes(bytes);

              // Upload story
              await ref.read(statusProfilesProvider.notifier).createStory([file.path], isCollage: widget.isCollage);

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
        ),
        configs: ProImageEditorConfigs(
          designMode: ImageEditorDesignMode.material,
          paintEditor: const PaintEditorConfigs(enableZoom: true),
          mainEditor: MainEditorConfigs(
            enableZoom: true,
            widgets: MainEditorWidgets(
              // appBar: null, // Hide default app bar
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
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                                      onPressed: () =>
                                          _showEffectsSheet(editor),
                                      tooltip: 'Filters & Adjust',
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                      onPressed:
                                          editor.openPaintEditor, // Doodle
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
                                      onPressed:
                                          editor.openEmojiEditor, // Emoji
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
                    return _buildCustomBottomBar(editor, key);
                  },
                );
              },
            ),
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
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            border: const Border(top: BorderSide(color: Colors.white10)),
          ),
          child: SafeArea(
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      editor.addLayer(
                        WidgetLayer(
                          offset: Offset.zero,
                          scale: 1.0,
                          widget: Image.file(
                            File(image.path),
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }
                  },
                ),
                Spacer(),
                // Layout Button (only show if collage mode)
                if (widget.isCollage)
                  ElevatedButton.icon(
                    onPressed: () => _showLayoutPicker(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.grid_view_rounded, size: 18),
                    label: const Text(
                      'Layout',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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

  void _showLayoutPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 200,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Layout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5, // Example layouts
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          // Apply layout grid logic here
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.grid_on, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: const Text(
                  'Change Layout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEffectsSheet(ProImageEditorState editor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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
