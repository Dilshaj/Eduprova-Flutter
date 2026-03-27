import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/preview_view.dart';
import 'providers/resume_provider.dart';
import 'ai_resume_editor_screen.dart';
import 'widgets/builder_dock.dart';

class AiResumeScreen extends ConsumerStatefulWidget {
  final String resumeId;

  const AiResumeScreen({super.key, required this.resumeId});

  @override
  ConsumerState<AiResumeScreen> createState() => _AiResumeScreenState();
}

class _AiResumeScreenState extends ConsumerState<AiResumeScreen> {
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // appBar: AppBar(
      //   // title: const Text('AI Resume Builder'),
      //   // backgroundColor: theme.scaffoldBackgroundColor,
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   scrolledUnderElevation: 0,
      // ),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        // leading: IconButton(
        //   icon: Container(
        //     padding: const EdgeInsets.all(8),
        //     decoration: BoxDecoration(
        //       gradient: LinearGradient(
        //         colors: [
        //           theme.colorScheme.primary,
        //           theme.colorScheme.primary.withValues(alpha: 0.8),
        //         ],
        //       ),
        //       shape: BoxShape.circle,
        //     ),
        //     child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        //   ),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Hero(
                tag: 'back_button',
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Center(child: _buildFloatingTabBar(context, theme)),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: _buildFloatingTabBar(context, theme),
      body: Stack(
        children: const [
          Positioned.fill(child: PreviewView()),
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: Center(child: BuilderDock()),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingTabBar(BuildContext context, ThemeData theme) {
    return Center(
      child: Hero(
        tag: 'tab_container',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            // color: Colors.red,
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.8,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FloatingTabButton(
                heroTag: 'tab_content',
                icon: Icons.edit_note,
                label: 'Content',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const AiResumeEditorScreen(initialIndex: 0),
                    ),
                  );
                },
                theme: theme,
              ),
              const SizedBox(width: 8),
              _FloatingTabButton(
                heroTag: 'tab_design',
                icon: Icons.palette_outlined,
                label: 'Design',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const AiResumeEditorScreen(initialIndex: 1),
                    ),
                  );
                },
                theme: theme,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingTabButton extends StatelessWidget {
  final String heroTag;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ThemeData theme;

  const _FloatingTabButton({
    required this.heroTag,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
