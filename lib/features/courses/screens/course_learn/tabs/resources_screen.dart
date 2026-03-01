import 'package:flutter/material.dart';
import 'package:eduprova/theme.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  void _handleDownload(BuildContext context, Map<String, dynamic> item) {
    // Simulate Download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting download for ${item['title']}')),
    );
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${item['title']} has been downloaded to your device.',
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> resources = [
      {
        'id': 1,
        'title': 'Lecture Slides.pdf',
        'size': '2.4 MB',
        'type': 'pdf',
        'icon': Icons.description_outlined,
      },
      {
        'id': 2,
        'title': 'Project Starter Files.zip',
        'size': '15 MB',
        'type': 'zip',
        'icon': Icons.folder_open_outlined,
      },
      {
        'id': 3,
        'title': 'Cheat Sheet - Module 1.pdf',
        'size': '1.1 MB',
        'type': 'pdf',
        'icon': Icons.description_outlined,
      },
      {
        'id': 4,
        'title': 'Cheat Sheet - Module 1.pdf',
        'size': '1.1 MB',
        'type': 'pdf',
        'icon': Icons.description_outlined,
      },
      {
        'id': 5,
        'title': 'Cheat Sheet - Module 1.pdf',
        'size': '1.1 MB',
        'type': 'pdf',
        'icon': Icons.description_outlined,
      },
      {
        'id': 6,
        'title': 'Cheat Sheet - Module 1.pdf',
        'size': '1.1 MB',
        'type': 'pdf',
        'icon': Icons.description_outlined,
      },
      {
        'id': 7,
        'title': 'Cheat Sheet - Module 1.pdf',
        'size': '1.1 MB',
        'type': 'pdf',
        'icon': Icons.description_outlined,
      },
      {
        'id': 8,
        'title': 'Cheat Sheet - Module 1.pdf',
        'size': '1.1 MB',
        'type': 'pdf',
        'icon': Icons.description_outlined,
      },
    ];

    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: themeExt.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: ListView.separated(
          itemCount: resources.length,
          padding: .only(top: 48),
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = resources[index];
            return InkWell(
              onTap: () => _handleDownload(context, item),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeExt.cardColor,
                  border: Border.all(color: themeExt.borderColor),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (themeExt.shadowColor != Colors.transparent)
                      BoxShadow(
                        color: themeExt.shadowColor,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon Box
                    Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        item['icon'],
                        size: 24,
                        color: colorScheme.primary,
                      ),
                    ),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['size'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: themeExt.secondaryText,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Download Button
                    InkWell(
                      onTap: () => _handleDownload(context, item),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: themeExt.skeletonBase,
                          border: Border.all(color: themeExt.borderColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.file_download_outlined,
                          size: 20,
                          color: themeExt.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
