import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme.dart';
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
    final themeExt = theme.extension<AppDesignExtension>()!;

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
            _buildField(
              'Full Name',
              _nameController,
              'e.g. John Doe',
              theme,
              themeExt,
            ),
            const SizedBox(height: 16),
            _buildField(
              'Headline',
              _headlineController,
              'e.g. Senior Software Engineer',
              theme,
              themeExt,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    'Email',
                    _emailController,
                    'john@example.com',
                    theme,
                    themeExt,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildField(
                    'Phone',
                    _phoneController,
                    '+1 123 456 7890',
                    theme,
                    themeExt,
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildField(
              'Location',
              _locationController,
              'e.g. New York, USA',
              theme,
              themeExt,
            ),
            const SizedBox(height: 16),
            _buildField(
              'Website',
              _websiteController,
              'https://johndoe.com',
              theme,
              themeExt,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint,
    ThemeData theme,
    AppDesignExtension themeExt, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: themeExt.secondaryText.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: themeExt.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: themeExt.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: themeExt.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
