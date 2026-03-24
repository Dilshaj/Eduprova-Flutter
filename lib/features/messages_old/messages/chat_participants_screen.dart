import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ChatParticipantsScreen extends StatelessWidget {
  final dynamic conversation;
  final String currentUserId;

  const ChatParticipantsScreen({
    super.key,
    required this.conversation,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Participants',
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: conversation.participants.length,
        itemBuilder: (context, index) {
          final participant = conversation.participants[index];
          return _buildMemberTile(participant, isDarkMode, context);
        },
      ),
    );
  }

  Widget _buildMemberTile(
    dynamic participant,
    bool isDarkMode,
    BuildContext context,
  ) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final isAdmin = participant.role == 'admin';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFD3E4FF),
          shape: BoxShape.circle,
          image: participant.avatarUrl != null
              ? DecorationImage(
                  image: NetworkImage(participant.avatarUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        alignment: Alignment.center,
        child: participant.avatarUrl == null
            ? Text(
                participant.name.isNotEmpty
                    ? participant.name.substring(0, 1).toUpperCase()
                    : '?',
                style: GoogleFonts.inter(
                  color: const Color(0xFF0066FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              )
            : null,
      ),
      title: Text(
        participant.name,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(
        isAdmin ? 'Admin' : 'Member',
        style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
      ),
      trailing: IconButton(
        icon: const Icon(LucideIcons.messageSquare, color: Color(0xFF0066FF)),
        onPressed: () {},
      ),
    );
  }
}
