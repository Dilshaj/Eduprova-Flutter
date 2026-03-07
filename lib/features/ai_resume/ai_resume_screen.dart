import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme.dart';
import 'widgets/section_list_view.dart';
import 'widgets/design_view.dart';
import 'widgets/preview_view.dart';
import 'providers/resume_provider.dart';

class AiResumeScreen extends ConsumerStatefulWidget {
  final String resumeId;

  const AiResumeScreen({super.key, required this.resumeId});

  @override
  ConsumerState<AiResumeScreen> createState() => _AiResumeScreenState();
}

class _AiResumeScreenState extends ConsumerState<AiResumeScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initResume());
  }

  Future<void> _initResume() async {
    await ref.read(resumeProvider.notifier).loadResume(widget.resumeId);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('AI Resume Builder'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [_buildToggle(theme, themeExt), const SizedBox(width: 16)],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildToggle(ThemeData theme, AppDesignExtension themeExt) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleItem(
            icon: Icons.edit_note,
            label: 'Content',
            isSelected: _selectedIndex == 0,
            onTap: () => setState(() => _selectedIndex = 0),
          ),
          _ToggleItem(
            icon: Icons.palette_outlined,
            label: 'Design',
            isSelected: _selectedIndex == 1,
            onTap: () => setState(() => _selectedIndex = 1),
          ),
          _ToggleItem(
            icon: Icons.remove_red_eye_outlined,
            label: 'Preview',
            isSelected: _selectedIndex == 2,
            onTap: () => setState(() => _selectedIndex = 2),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _selectedIndex,
      children: const [SectionListView(), DesignView(), PreviewView()],
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : theme.iconTheme.color?.withValues(alpha: 0.7),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
