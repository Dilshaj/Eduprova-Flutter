import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommunityCategoriesScreen extends StatefulWidget {
  final String? category;
  const CommunityCategoriesScreen({super.key, this.category});

  @override
  State<CommunityCategoriesScreen> createState() =>
      _CommunityCategoriesScreenState();
}

class _CommunityCategoriesScreenState extends State<CommunityCategoriesScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _handleCreate() {
    if (_nameController.text.trim().isEmpty) return;
    final communityName = _nameController.text.trim();
    final category = widget.category;
    Navigator.pop(context); // Close current screen
    Navigator.pop(context, {
      'name': communityName,
      'category': category,
    }); // Close Create community screen
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Community "$communityName" created successfully!'),
        backgroundColor: const Color(0xFF0066FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.category ?? 'Create your community';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(16),
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: isDarkMode ? Colors.white70 : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Upload
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isDarkMode ? Colors.white10 : const Color(0xFFE2E8F0),
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 24,
                                color: isDarkMode ? Colors.white38 : const Color(0xFF94A3B8),
                              ),
                            ),
                            Positioned(
                              bottom: -10,
                              left: 25,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                                  border: Border.all(
                                    color: isDarkMode ? Colors.white10 : const Color(0xFFE2E8F0),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      size: 10,
                                      color: isDarkMode ? Colors.white70 : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'EDIT',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white70 : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Community Name
                        Text(
                          'COMMUNITY NAME',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDarkMode ? Colors.white10 : const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'e.g. CS Sophomore Study Group',
                              hintStyle: GoogleFonts.inter(
                                color: isDarkMode ? Colors.white24 : const Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Description
                        Text(
                          'DESCRIPTION (OPTIONAL)',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF1E293B).withOpacity(0.5) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDarkMode ? Colors.white10 : Colors.transparent),
                          ),
                          child: TextField(
                            controller: _descController,
                            maxLines: null,
                            expands: true,
                            decoration: InputDecoration(
                              hintText:
                                  "Write a short description about your community so people know what it's about.",
                              hintStyle: GoogleFonts.inter(
                                color: isDarkMode ? Colors.white24 : const Color(0xFF94A3B8),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            textAlignVertical: TextAlignVertical.top,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: isDarkMode ? Colors.white70 : const Color(0xFF475569),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Guidelines
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF0066FF).withOpacity(0.05) : const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isDarkMode ? Colors.blue.withOpacity(0.2) : const Color(0xFFE0F2FE)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Community guidelines',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                    color: Color(0xFF0066FF),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: isDarkMode ? Colors.white60 : const Color(0xFF475569),
                                    height: 1.6,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text:
                                          "Be kind and respectful to your fellow community members. Don't be rude or cruel. Participate as yourself and don't post anything that violates ",
                                    ),
                                    TextSpan(
                                      text: 'Community Standards',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: const Color(0xFF0066FF),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const TextSpan(text: '.'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Footer
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.chevron_left,
                          size: 20,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Back',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0066FF), Color(0xFFC026D3)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFA855F7).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handleCreate,
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Center(
                            child: Text(
                              'Create',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
