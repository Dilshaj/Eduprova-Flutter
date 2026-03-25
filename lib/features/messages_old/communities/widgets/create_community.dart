import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'scratch_page.dart';
import 'community_categories.dart';

class CreateCommunityScreen extends StatelessWidget {
  const CreateCommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 48 - 12) / 2;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final categories = [
      {
        'icon': Icons.menu_book,
        'label': 'Study Groups',
        'color': const Color(0xFFF97316),
        'bgColor': const Color(0xFFFFEDD5),
      },
      {
        'icon': Icons.trending_up,
        'label': 'Career Growth',
        'color': const Color(0xFF8B5CF6),
        'bgColor': const Color(0xFFEDE9FE),
      },
      {
        'icon': Icons.people,
        'label': 'Networking',
        'color': const Color(0xFF0066FF),
        'bgColor': const Color(0xFFDBEAFE),
      },
      {
        'icon': Icons.extension,
        'label': 'Project Collab',
        'color': const Color(0xFF10B981),
        'bgColor': const Color(0xFFD1FAE5),
      },
      {
        'icon': Icons.palette,
        'label': 'Art & Design',
        'color': const Color(0xFFEC4899),
        'bgColor': const Color(0xFFFCE7F3),
      },
      {
        'icon': Icons.code,
        'label': 'Coding Hub',
        'color': const Color(0xFF64748B),
        'bgColor': const Color(0xFFF1F5F9),
      },
      {
        'icon': Icons.celebration,
        'label': 'Social & Fun',
        'color': const Color(0xFFEAB308),
        'bgColor': const Color(0xFFFEF9C3),
      },
      {
        'icon': Icons.school,
        'label': 'Mentorship',
        'color': const Color(0xFF06B6D4),
        'bgColor': const Color(0xFFCFFAFE),
      },
    ];

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create a community',
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Select how you'd like to bring your students together.",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: isDarkMode
                                ? Colors.white70
                                : const Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white10
                            : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: isDarkMode
                            ? Colors.white70
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Start from Scratch
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ScratchPageScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.white10
                                  : const Color(0xFFF1F5F9),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDarkMode
                                      ? Colors.blue.withOpacity(0.1)
                                      : const Color(0xFFDBEAFE),
                                ),
                                alignment: Alignment.center,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF0066FF),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Start from scratch',
                                      style: GoogleFonts.inter(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Full control over your structure and settings.',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: isDarkMode
                                            ? Colors.white60
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: isDarkMode
                                    ? Colors.white24
                                    : const Color(0xFFCBD5E1),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      Text(
                        'COMMUNITY CATEGORIES',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Grid
                      Wrap(
                        spacing: 12,
                        runSpacing: 0,
                        children: categories.map((cat) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CommunityCategoriesScreen(
                                    category: cat['label'] as String,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: cardWidth,
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.white10
                                      : const Color(0xFFF8FAFC),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? (cat['color'] as Color).withOpacity(
                                              0.15,
                                            )
                                          : cat['bgColor'] as Color,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      cat['icon'] as IconData,
                                      size: 20,
                                      color: cat['color'] as Color,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      cat['label'] as String,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : const Color(0xFF1E293B),
                                      ),
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
