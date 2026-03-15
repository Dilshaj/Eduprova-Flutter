import 'package:eduprova/constants.dart';
import 'package:eduprova/theme/theme.dart';
import 'package:eduprova/theme/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateChannelScreen extends StatefulWidget {
  const CreateChannelScreen({super.key});

  @override
  State<CreateChannelScreen> createState() => _CreateChannelScreenState();
}

class _CreateChannelScreenState extends State<CreateChannelScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isPublic = true;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final subTextColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
        Colors.grey;
    final borderColor = Theme.of(context).dividerColor;
    final themeExt = context.design;
    final cs = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        title: const Text(''), // Empty title as per mockup (title is in body)
        actions: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: subTextColor, size: 20),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Create New Channel',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Channels are where your community communicates.',
              style: TextStyle(fontSize: 15, color: subTextColor),
            ),
            const SizedBox(height: 32),

            // Channel Name Field
            _buildLabel('CHANNEL NAME', subTextColor),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '# e.g. projects',
                hintStyle: TextStyle(
                  color: subTextColor.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]?.withValues(alpha: 0.3)
                    : const Color(0xFFF8F9FB),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Description Field
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel('DESCRIPTION', subTextColor),
                Text(
                  '(optional)',
                  style: TextStyle(
                    color: subTextColor.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'What is this channel about?',
                hintStyle: TextStyle(
                  color: subTextColor.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]?.withValues(alpha: 0.3)
                    : const Color(0xFFF8F9FB),
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Privacy Settings
            _buildLabel('PRIVACY SETTINGS', subTextColor),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPrivacyCard(
                    title: 'Public',
                    subtitle: 'Anyone in the hub can join',
                    icon: Icons.public_rounded,
                    isSelected: _isPublic,
                    onTap: () => setState(() => _isPublic = true),
                    borderColor: borderColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPrivacyCard(
                    title: 'Private',
                    subtitle: 'Invite only channel access',
                    icon: Icons.lock_rounded,
                    isSelected: !_isPublic,
                    onTap: () => setState(() => _isPublic = false),
                    borderColor: borderColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Create Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: themeExt.buyNowGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Create Channel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cancel Button
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: subTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildPrivacyCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color borderColor,
  }) {
    final activeColor = Colors.blue.shade600;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withValues(alpha: 0.05)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? activeColor : Colors.grey.shade600,
                    size: 20,
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: activeColor, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
