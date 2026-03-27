import 'package:flutter/material.dart';
import 'widgets/section_list_view.dart';
import 'widgets/design_view.dart';

class AiResumeEditorScreen extends StatefulWidget {
  final int initialIndex;

  const AiResumeEditorScreen({super.key, this.initialIndex = 0});

  @override
  State<AiResumeEditorScreen> createState() => _AiResumeEditorScreenState();
}

class _AiResumeEditorScreenState extends State<AiResumeEditorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: TabBarView(
        controller: _tabController,
        children: const [SectionListView(), DesignView()],
      ),

      // bottomNavigationBar: SafeArea(
      //   child:,
      // ),
      appBar: AppBar(
        // title: const Text('Edit Resume'),
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Hero(
              tag: 'back_button',
              child: IconButton(
                icon: Padding(
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.arrow_back_ios_new, size: 16),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(child: _buildTabBar()),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
    );
  }

  Widget _buildTabBar() {
    final theme = Theme.of(context);
    return Hero(
      tag: 'tab_container',
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.8,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            labelColor: Colors.white,
            labelStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelColor: theme.iconTheme.color?.withValues(alpha: 0.7),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.edit_note, size: 16),
                    const SizedBox(width: 6),
                    const Text('Content'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.palette_outlined, size: 16),
                    const SizedBox(width: 6),
                    const Text('Design'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
