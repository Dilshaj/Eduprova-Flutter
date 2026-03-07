import 'package:eduprova/features/courses/core/models/course_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:eduprova/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesScreen extends StatelessWidget {
  final List<AttachmentModel> resources;
  const ResourcesScreen({super.key, required this.resources});

  Future<void> _handleDownload(
    BuildContext context,
    AttachmentModel item,
  ) async {
    final url = Uri.parse(item.url);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open ${item.title}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.description_outlined;
      case 'zip':
      case 'rar':
        return Icons.folder_zip_outlined;
      case 'doc':
      case 'docx':
        return Icons.article_outlined;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_outlined;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Icons.image_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    if (resources.isEmpty) {
      return Scaffold(
        backgroundColor: themeExt.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_off_outlined,
                size: 64,
                color: themeExt.secondaryText.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No resources available for this course.',
                style: TextStyle(color: themeExt.secondaryText, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: themeExt.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: ListView.separated(
          itemCount: resources.length,
          padding: .only(top: 48, bottom: 24),
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
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: themeExt.borderColor.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: themeExt.shadowColor.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconForType(item.type),
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.type.toUpperCase(),
                            style: TextStyle(
                              color: themeExt.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.file_download_outlined,
                      color: themeExt.secondaryText,
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
