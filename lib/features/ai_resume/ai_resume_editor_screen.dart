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
      appBar: AppBar(
        title: const Text('Edit Resume'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [SectionListView(), DesignView()],
      ),
      bottomNavigationBar: SafeArea(
        child: Hero(
          tag: 'tab_container',
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              padding: const EdgeInsets.all(6),
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
                unselectedLabelColor: theme.iconTheme.color?.withValues(
                  alpha: 0.7,
                ),
                tabs: [
                  Tab(
                    // child: Hero(
                    //   tag: 'tab_content',
                    //   child: Material(
                    //     color: Colors.transparent,
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         const Icon(Icons.edit_note, size: 16),
                    //         const SizedBox(width: 6),
                    //         const Text(
                    //           'Content',
                    //           style: TextStyle(
                    //             fontSize: 12,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    child: Material(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.edit_note, size: 16),
                          const SizedBox(width: 6),
                          const Text(
                            'Content',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    // child: Hero(
                    //   tag: 'tab_design',
                    //   child: Material(
                    //     color: Colors.transparent,
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         const Icon(Icons.palette_outlined, size: 16),
                    //         const SizedBox(width: 6),
                    //         const Text(
                    //           'Design',
                    //           style: TextStyle(
                    //             fontSize: 12,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    child: Material(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.palette_outlined, size: 16),
                          const SizedBox(width: 6),
                          const Text(
                            'Design',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
