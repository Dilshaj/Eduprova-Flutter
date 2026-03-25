import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NewMeetingScreen extends StatelessWidget {
  const NewMeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedule Meeting',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create a meeting for your team',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? colorScheme.surfaceContainerHighest : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        LucideIcons.x,
                        size: 20,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Meeting Title
              _buildInputLabel(
                label: 'Meeting Title',
                icon: LucideIcons.fileText,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                hint: 'e.g., Weekly Standup',
                colorScheme: colorScheme,
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // Description
              _buildInputLabel(
                label: 'Description',
                icon: LucideIcons.list,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                hint: "What's this meeting about?",
                maxLines: 4,
                colorScheme: colorScheme,
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // Date
              _buildInputLabel(
                label: 'Date',
                icon: LucideIcons.calendar,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 12),
              _buildDateTimeField(
                text: '24-03-2026',
                trailingIcon: LucideIcons.calendar,
                colorScheme: colorScheme,
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // Start and End Time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel(
                          label: 'Start Time',
                          icon: LucideIcons.clock,
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 12),
                        _buildDateTimeField(
                          text: '10:00',
                          trailingIcon: LucideIcons.clock,
                          colorScheme: colorScheme,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel(
                          label: 'End Time',
                          icon: LucideIcons.clock,
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 12),
                        _buildDateTimeField(
                          text: '11:00',
                          trailingIcon: LucideIcons.clock,
                          colorScheme: colorScheme,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Add Participants
              _buildInputLabel(
                label: 'Add Participants',
                icon: LucideIcons.users,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                hint: 'Search by name or email...',
                colorScheme: colorScheme,
                isDark: isDark,
              ),
              const SizedBox(height: 48),

              // Gradient Schedule Button
              _buildGradientButton(
                context: context,
                text: 'Schedule Meeting',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066FF).withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel({
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String hint,
    int maxLines = 1,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: GoogleFonts.inter(
          fontSize: 14,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildDateTimeField({
    required String text,
    required IconData trailingIcon,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          Icon(
            trailingIcon,
            size: 18,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}
