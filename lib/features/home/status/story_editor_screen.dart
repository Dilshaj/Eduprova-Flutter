import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

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
            // Edit complete
            Navigator.pop(context);
          },
        ),
        configs: ProImageEditorConfigs(
          designMode: ImageEditorDesignMode.material,
          paintEditor: const PaintEditorConfigs(enableZoom: true),
          mainEditor: MainEditorConfigs(
            enableZoom: true,
            widgets: MainEditorWidgets(
              wrapBody: (editor, rebuildStream, content) {
                return ReactiveWidget(
                  stream: rebuildStream,
                  builder: (_) => Stack(
                    children: [
                      content,
                      if (!editor.isSubEditorOpen)
                        Positioned(
                          top: MediaQuery.paddingOf(context).top + 16,
                          right: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.tune),
                                  onPressed: editor.openTuneEditor, // Tune
                                ),
                                IconButton(
                                  icon: const Icon(Icons.auto_awesome),
                                  onPressed: editor.openFilterEditor, // Filters
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: editor.openPaintEditor, // Doodle
                                ),
                                IconButton(
                                  icon: const Icon(Icons.text_fields),
                                  onPressed: editor.openTextEditor, // Text
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.sentiment_satisfied_alt,
                                  ),
                                  onPressed: editor.openEmojiEditor, // Emoji
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Widget _buildCustomBottomBar(ProImageEditorState editor, Key key) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            // Layout Button (only show if collage mode)
            if (widget.isCollage)
              ElevatedButton.icon(
                onPressed: () {
                  // Show Layout Picker Bottom Sheet
                  _showLayoutPicker();
                },
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
}
