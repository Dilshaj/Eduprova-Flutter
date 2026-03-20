import 'package:eduprova/theme/theme_model.dart';
import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final TabController tabController;
  final List<String> tabs;
  const CustomTabBar({
    super.key,
    required this.tabController,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHighest,
      clipBehavior: .antiAlias,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 48,
        child: TabBar(
          controller: tabController,
          indicator: BoxDecoration(
            color: themeExt.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: themeExt.borderColor),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(6),
          labelColor: colorScheme.onSurface,
          unselectedLabelColor: themeExt.secondaryText,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          dividerColor: Colors.transparent,
          tabs: tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
    );
  }
}
