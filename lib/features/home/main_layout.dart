import 'package:eduprova/core/navigation/app_routes.dart';
import 'package:eduprova/features/home/bottom_nav/bottom_nav4.dart';
import 'package:eduprova/features/auth/providers/auth_provider.dart';
import 'package:eduprova/core/widgets/dev_server_config_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<ScaffoldState> mainScaffoldKey = GlobalKey<ScaffoldState>();

class MainLayout extends StatelessWidget {
  const MainLayout({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: mainScaffoldKey,
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Streaks Section
              const Text(
                'Streaks',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('🔥', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                          Text(
                            '11.2k',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('🏆', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                          Text(
                            '20.6hrs',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Featured Posts Section
              const Text(
                'Featured Posts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  children: [
                    ListTile(title: const Text('Trending Posts'), onTap: () {}),
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                    ListTile(title: const Text('Following'), onTap: () {}),
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                    ListTile(title: const Text('Latest Posts'), onTap: () {}),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // AI Tools Section
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
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Grammar Correction'),
                      onTap: () {
                        context.pop();
                        context.push(AppRoutes.grammar);
                      },
                    ),
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                    ListTile(
                      title: const Text('Resume Builder'),
                      onTap: () {
                        // close drawer
                        context.pop();
                        context.push(AppRoutes.resumeBuilderHome);
                      },
                    ),
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                    ListTile(
                      title: const Text('Interview Assistant'),
                      onTap: () {
                        // close drawer
                        context.pop();
                        context.push(AppRoutes.aiInterview);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Freelance Section
              const Text(
                'Freelance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  children: [
                    ListTile(title: const Text('Freelancing'), onTap: () {}),
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                    ExpansionTile(
                      title: const Text('Startup Hub'),
                      shape: const Border(),
                      children: [
                        ListTile(
                          title: const Text('Find Investors'),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'App Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.dns_outlined),
                      title: const Text('Dev API URL'),
                      subtitle: const Text('Change backend IP for testing'),
                      onTap: () {
                        Navigator.pop(context);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final rootContext =
                              mainScaffoldKey.currentContext ?? context;
                          showDevServerConfigDialog(rootContext);
                        });
                      },
                    ),
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                    Consumer(
                      builder: (context, ref, child) {
                        return ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('Logout'),
                          onTap: () async {
                            Navigator.pop(context);
                            await ref.read(authProvider.notifier).logout();
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
