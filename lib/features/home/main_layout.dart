import 'package:eduprova/core/navigation/app_routes.dart';
import 'package:eduprova/core/providers/theme_provider.dart';
import 'package:eduprova/features/auth/providers/auth_provider.dart';
import 'package:eduprova/features/home/bottom_nav/bottom_nav3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final GlobalKey<ScaffoldState> mainScaffoldKey = GlobalKey<ScaffoldState>();

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: mainScaffoldKey,
      extendBody: true,
      drawer: _buildDrawer(context, isDark, ref),
      body: navigationShell,
      bottomNavigationBar: BottomNav3(
        currentIndex: navigationShell.currentIndex >= 2
            ? navigationShell.currentIndex + 1
            : navigationShell.currentIndex,
        onTap: (index) {
          if (index == 2) {
            // Placeholder: Open Create Post Modal
          } else {
            final branchIndex = index > 2 ? index - 1 : index;
            navigationShell.goBranch(branchIndex);
          }
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark, WidgetRef ref) {
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF3F7FF);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final subTextColor = isDark ? Colors.grey[400] : const Color(0xFF6B7280);

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Profile Info
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: textColor.withValues(alpha: 0.1),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200&h=200&fit=crop',
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rahul Gamer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Student',
                          style: TextStyle(
                            fontSize: 13,
                            color: subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildHeaderIcon(
                    context,
                    isDark ? LucideIcons.sun : LucideIcons.moon,
                    isDark,
                    onTap: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                  ),
                  const SizedBox(width: 10),
                  _buildHeaderIcon(
                    context,
                    LucideIcons.pencil,
                    isDark,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Favorites and Bookmark Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      context,
                      LucideIcons.heart,
                      'Favourites',
                      cardColor,
                      textColor,
                      onTap: () {
                        context.pop();
                        context.push(AppRoutes.likedPosts);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionButton(
                      context,
                      LucideIcons.bookmark,
                      'Saved',
                      cardColor,
                      textColor,
                      onTap: () {
                        context.pop();
                        context.push(AppRoutes.savedPosts);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Feed Section
              _buildSectionCard(
                context,
                [
                  _buildDrawerItem(context, LucideIcons.rss, 'For you', textColor, onTap: () {
                    context.pop();
                    navigationShell.goBranch(0);
                  }),
                  _buildDrawerItem(context, LucideIcons.users, 'Following', textColor, isLast: true, onTap: () {
                    context.pop();
                    // Optional: navigate to a following-filtered view if exists
                  }),
                ],
                cardColor,
              ),
              const SizedBox(height: 24),


              // COMMUNITY Section
              _buildSectionHeader('COMMUNITY', subTextColor!),
              _buildSectionCard(
                context,
                [
                  _buildDrawerItem(context, LucideIcons.briefcase, 'Job Board', textColor, onTap: () {
                    context.pop();
                    context.push(AppRoutes.jobs);
                  }),
                  _buildDrawerItem(context, LucideIcons.handshake, 'Freelancing', textColor, isLast: true, onTap: () {
                    context.pop();
                    // context.push(AppRoutes.freelance); // Add route if exists
                  }),
                ],
                cardColor,
              ),
              const SizedBox(height: 24),

              // AI TOOLS Section
              _buildSectionHeader('AI TOOLS', subTextColor!),
              _buildSectionCard(
                context,
                [
                  _buildDrawerItem(context, LucideIcons.languages, 'Grammar Assistant', textColor, onTap: () {
                    context.pop();
                    context.push(AppRoutes.grammar);
                  }),
                  _buildDrawerItem(context, LucideIcons.fileText, 'Resume Builder', textColor, onTap: () {
                    context.pop();
                    context.push(AppRoutes.resumeBuilderHome);
                  }),
                  _buildDrawerItem(context, LucideIcons.video, 'Mock Interview', textColor, isLast: true, onTap: () {
                    context.pop();
                    context.push(AppRoutes.aiInterview);
                  }),
                ],
                cardColor,
              ),
              const SizedBox(height: 24),

              // Settings & Logout Footer
              _buildSectionCard(
                context,
                [
                  _buildDrawerItem(
                    context,
                    LucideIcons.settings,
                    'Settings',
                    textColor,
                    onTap: () {
                      context.pop();
                      context.push(AppRoutes.profileSettings);
                    },
                  ),
                  InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      await ref.read(authProvider.notifier).logout();
                    },
                    splashColor: Colors.transparent,
                    highlightColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.logOut, color: Color(0xFF6B7280), size: 22),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  'EDUPROVA V2.4.0',
                                  style: TextStyle(fontSize: 10, color: subTextColor),
                                ),
                              ],
                            ),
                          ),
                          const Icon(LucideIcons.chevronRight, size: 18, color: Color(0xFF9E9E9E)),
                        ],
                      ),
                    ),
                  ),
                ],
                cardColor,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(BuildContext context, IconData icon, String label, Color cardColor, Color textColor, {VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(20),
      splashColor: Colors.transparent,
      highlightColor: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.03),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color.withValues(alpha: 0.8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, List<Widget> items, Color cardColor) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    Color color, {
    bool isLast = false,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        InkWell(
          onTap: onTap ?? () {},
          borderRadius: isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(20))
              : (title == 'For you' || title == 'Home' || title == 'Job Board' || title == 'Grammar Assistant'
                  ? const BorderRadius.vertical(top: Radius.circular(20))
                  : null),
          splashColor: Colors.transparent,
          highlightColor: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF8B5CF6) : Colors.transparent,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                  ),
                ),
                const SizedBox(width: 14),
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 52,
            endIndent: 20,
            color: Colors.black.withValues(alpha: 0.05),
          ),
      ],
    );
  }

  Widget _buildHeaderIcon(BuildContext context, IconData icon, bool isDark, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isDark ? Colors.white : const Color(0xFF1F2937), size: 18),
      ),
    );
  }
}
