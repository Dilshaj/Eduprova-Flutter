import 'package:eduprova/features/home/bottom_nav/bottom_nav4.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<ScaffoldState> mainScaffoldKey2 = GlobalKey<ScaffoldState>();

class MainLayout2 extends StatelessWidget {
  const MainLayout2({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: mainScaffoldKey2,
      extendBody: true,
      drawer: _buildDrawer(context, isDark),
      body: navigationShell,
      bottomNavigationBar: BottomNav4(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark) {
    return Drawer(
      width: 340,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Streaks ──────────────────────────────────────────────────
              const Text(
                'Streaks',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _drawerStatCard('🔥', '11.2k', context)),
                  const SizedBox(width: 12),
                  Expanded(child: _drawerStatCard('🏆', '20.6hrs', context)),
                ],
              ),
              const SizedBox(height: 24),

              // ── Featured Posts ────────────────────────────────────────────
              const Text(
                'Featured Posts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _drawerCard(context, [
                ListTile(title: const Text('Trending Posts'), onTap: () {}),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                ListTile(title: const Text('Following'), onTap: () {}),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                ListTile(title: const Text('Latest Posts'), onTap: () {}),
              ]),
              const SizedBox(height: 24),

              // ── AI Tools ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AI Tools',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _drawerCard(context, [
                ListTile(title: const Text('Grammar Correction'), onTap: () {}),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                ListTile(title: const Text('Resume Builder'), onTap: () {}),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                ListTile(
                  title: const Text('Interview Assistant'),
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 24),

              // ── Freelance ─────────────────────────────────────────────────
              const Text(
                'Freelance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _drawerCard(context, [
                ListTile(title: const Text('Freelancing'), onTap: () {}),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                ExpansionTile(
                  title: const Text('Startup Hub'),
                  shape: const Border(),
                  children: [
                    ListTile(title: const Text('Find Investors'), onTap: () {}),
                  ],
                ),
              ]),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerStatCard(String emoji, String value, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _drawerCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(children: children),
    );
  }
}
