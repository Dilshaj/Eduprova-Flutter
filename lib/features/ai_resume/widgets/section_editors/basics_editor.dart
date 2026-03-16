import 'package:eduprova/features/ai_resume/widgets/basic_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';

class BasicsEditor extends ConsumerStatefulWidget {
  const BasicsEditor({super.key});

  @override
  ConsumerState<BasicsEditor> createState() => _BasicsEditorState();
}

class _BasicsEditorState extends ConsumerState<BasicsEditor> {
  late TextEditingController _nameController;
  late TextEditingController _headlineController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _websiteController;

  @override
  void initState() {
    super.initState();
    final basics = ref.read(resumeProvider).basics;
    _nameController = TextEditingController(text: basics.name);
    _headlineController = TextEditingController(text: basics.headline);
    _emailController = TextEditingController(text: basics.email);
    _phoneController = TextEditingController(text: basics.phone);
    _locationController = TextEditingController(text: basics.location);
    _websiteController = TextEditingController(text: basics.website.url);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _headlineController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _save() {
    final basics = ref.read(resumeProvider).basics;
    final newBasics = Basics(
      name: _nameController.text,
      headline: _headlineController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      location: _locationController.text,
      website: Url(url: _websiteController.text, label: basics.website.label),
      customFields: basics.customFields,
    );
    ref.read(resumeProvider.notifier).updateBasics(newBasics);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Personal Details'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            BasicInput(
              label: 'Full Name',
              controller: _nameController,
              hint: 'e.g. John Doe',
            ),
            const SizedBox(height: 16),
            BasicInput(
              label: 'Headline',
              controller: _headlineController,
              hint: 'e.g. Senior Software Engineer',
            ),
            const SizedBox(height: 16),
            BasicInput(
              label: 'Email',
              controller: _emailController,
              hint: 'john@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            BasicInput(
              label: 'Phone',
              controller: _phoneController,
              hint: '+1 123 456 7890',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            BasicInput(
              label: 'Location',
              controller: _locationController,
              hint: 'e.g. New York, USA',
            ),
            const SizedBox(height: 16),
            BasicInput(
              label: 'Website',
              controller: _websiteController,
              hint: 'https://johndoe.com',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
