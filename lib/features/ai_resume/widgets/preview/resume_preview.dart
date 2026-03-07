import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/resume_provider.dart';
import 'templates/resume_template.dart';

class ResumePreview extends ConsumerWidget {
  const ResumePreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resume = ref.watch(resumeProvider);
    final metadata = resume.metadata;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
      child: Center(
        child: InteractiveViewer(
          minScale: 0.1,
          maxScale: 3.0,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          constrained: false, // Allows child to have its own size
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var (index, pageLayout) in metadata.layout.pages.indexed)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Container(
                    width: 595.0,
                    height: 842.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ResumeTemplates.getTemplate(
                      metadata.template,
                      pageIndex: index,
                      pageLayout: pageLayout,
                      resume: resume,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
