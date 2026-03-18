import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/messages_background.dart';
import '../../models/conversation_model.dart';
import 'chat_avatar.dart';

class TeamProfileScreen extends StatelessWidget {
  final String teamName;
  final String teamAvatar;
  final int participantsCount;
  final ConversationModel? conversation;

  const TeamProfileScreen({
    super.key,
    required this.teamName,
    required this.teamAvatar,
    required this.participantsCount,
    this.conversation,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == .dark;

    return MessagesBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Team Info',
            style: GoogleFonts.inter(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: .bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const .symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Team Icon
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
                    ),
                  ),
                  alignment: .center,
                  child: conversation != null
                      ? ChatAvatar(
                          conversation: conversation,
                          currentUserId: '',
                          size: 108,
                        )
                      : (teamAvatar.isNotEmpty
                            ? CircleAvatar(
                                radius: 56,
                                backgroundImage: NetworkImage(teamAvatar),
                              )
                            : Text(
                                teamName.substring(0, 1).toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 48,
                                  fontWeight: .bold,
                                  color: Colors.white,
                                ),
                              )),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                teamName,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: .bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Text(
                '$participantsCount Participants',
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: .spaceEvenly,
                children: [
                  _buildActionIcon(
                    Icons.person_add_outlined,
                    'Add',
                    isDarkMode,
                  ),
                  _buildActionIcon(Icons.search, 'Find', isDarkMode),
                  _buildActionIcon(
                    Icons.notifications_outlined,
                    'Mute',
                    isDarkMode,
                  ),
                  _buildActionIcon(Icons.videocam_outlined, 'Meet', isDarkMode),
                ],
              ),

              const SizedBox(height: 40),

              // Members Section
              _buildSectionHeader('Participants', isDarkMode),
              const SizedBox(height: 16),
              if (conversation != null)
                ...conversation!.participants.map(
                  (p) => _buildMemberTileFromParticipant(p, isDarkMode),
                )
              else
                ...List.generate(
                  4,
                  (index) => _buildMemberTile(index, isDarkMode),
                ),

              TextButton(
                onPressed: () {},
                child: Text(
                  'View all participants',
                  style: GoogleFonts.inter(color: const Color(0xFF0066FF)),
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('Group Settings', isDarkMode),
              const SizedBox(height: 12),
              _buildListTile(
                Icons.info_outline,
                'Description',
                conversation?.description ?? 'No description.',
                isDarkMode,
                isRed: false,
              ),
              _buildListTile(
                Icons.link,
                'Invite Link',
                'eduprova.com/j/${conversation?.id ?? 'design-team'}',
                isDarkMode,
                isRed: false,
              ),

              const SizedBox(height: 24),
              _buildListTile(
                Icons.exit_to_app,
                'Leave Group',
                '',
                isDarkMode,
                isRed: true,
              ),
              _buildListTile(
                Icons.delete_outline,
                'Delete Group',
                '',
                isDarkMode,
                isRed: true,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String label, bool isDarkMode) {
    return Column(
      children: [
        Container(
          padding: const .all(12),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isDarkMode ? Colors.white : Colors.black),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Align(
      alignment: .centerLeft,
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: .bold,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildMemberTileFromParticipant(
    ConversationMember member,
    bool isDarkMode,
  ) {
    final name = member.user != null
        ? '${member.user!.firstName} ${member.user!.lastName}'
        : 'Unknown Member';
    final avatar = member.user?.avatar ?? '';
    final role = member.role == 'admin' ? 'Admin' : 'Participant';

    return ListTile(
      contentPadding: .zero,
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
        child: avatar.isEmpty ? Text(name.substring(0, 1).toUpperCase()) : null,
      ),
      title: Text(
        name,
        style: GoogleFonts.inter(
          color: isDarkMode ? Colors.white : Colors.black,
          fontWeight: .w500,
        ),
      ),
      subtitle: Text(
        role,
        style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
      ),
      trailing: const Icon(
        Icons.message_outlined,
        size: 18,
        color: Colors.blueAccent,
      ),
      onTap: () {},
    );
  }

  Widget _buildMemberTile(int index, bool isDarkMode) {
    final names = [
      'Sarah Chen',
      'Surya Sarisa',
      'Rose Nguyen',
      'Chester Martin',
    ];
    return ListTile(
      contentPadding: .zero,
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage('https://i.pravatar.cc/100?u=team$index'),
      ),
      title: Text(
        names[index % names.length],
        style: GoogleFonts.inter(
          color: isDarkMode ? Colors.white : Colors.black,
          fontWeight: .w500,
        ),
      ),
      subtitle: Text(
        index == 0 ? 'Admin' : 'Participant',
        style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
      ),
      trailing: const Icon(
        Icons.message_outlined,
        size: 18,
        color: Colors.blueAccent,
      ),
      onTap: () {},
    );
  }

  Widget _buildListTile(
    IconData icon,
    String label,
    String value,
    bool isDarkMode, {
    required bool isRed,
  }) {
    return ListTile(
      contentPadding: .zero,
      leading: Icon(
        icon,
        color: isRed
            ? Colors.redAccent
            : (isDarkMode ? Colors.white70 : Colors.black54),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: isRed
              ? Colors.redAccent
              : (isDarkMode ? Colors.white : Colors.black),
          fontSize: 16,
          fontWeight: .w500,
        ),
      ),
      subtitle: value.isNotEmpty
          ? Text(
              value,
              style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {},
    );
  }
}
