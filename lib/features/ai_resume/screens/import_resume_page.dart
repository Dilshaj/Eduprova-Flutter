import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/navigation/app_routes.dart';
import '../providers/resume_list_provider.dart';

class ImportResumePage extends ConsumerStatefulWidget {
  const ImportResumePage({super.key});

  @override
  ConsumerState<ImportResumePage> createState() => _ImportResumePageState();
}

class _ImportResumePageState extends ConsumerState<ImportResumePage> {
  bool _isLoading = false;
  String? _error;

  Future<void> _pickAndImport() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isLoading = true;
          _error = null;
        });

        final file = File(result.files.single.path!);
        final repo = ref.read(resumeRepositoryProvider);

        // 1. Upload to parse
        final parsedData = await repo.importResume(file);

        // 2. Create the resume on backend with this parsed data
        final title = 'Imported Resume (${result.files.single.name})';
        final slug = const Uuid().v4();
        final response = await repo.createResume(title, slug, parsedData);
        final newId = response['_id'] as String;

        // 3. Refresh list and navigate
        await ref.read(resumeListProvider.notifier).loadResumes();

        if (mounted) {
          context.pushReplacement(AppRoutes.resumeBuilderEditor(newId));
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Resume')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.fileUp,
                size: 80,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 24),
              const Text(
                'Import your existing resume',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Upload a PDF or DOCX file. Our AI will extract your details '
                'and pre-fill the builder for you.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Parsing your resume with AI...'),
                  ],
                )
              else
                FilledButton.icon(
                  onPressed: _pickAndImport,
                  icon: const Icon(LucideIcons.upload),
                  label: const Text('Select File'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
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
