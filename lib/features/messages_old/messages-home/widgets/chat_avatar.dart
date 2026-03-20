import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/image_cache_manager.dart';
import '../../models/conversation_model.dart';

class ChatAvatar extends StatelessWidget {
  final ConversationModel? conversation;
  final String? currentUserId;
  final double size;

  const ChatAvatar({
    super.key,
    this.conversation,
    this.currentUserId,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    if (conversation == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
      );
    }

    final avatar = conversation!.getDisplayAvatar(currentUserId ?? '');
    final title = conversation!.getDisplayTitle(currentUserId ?? '');
    final isDarkMode = Theme.of(context).brightness == .dark;

    final borderColor = isDarkMode
        ? const Color(0xFF374151)
        : const Color(0xFFE5E7EB);

    if (avatar != null && avatar.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: .all(color: borderColor),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: avatar,
            cacheManager: CacheManagers.messageCacheManager,
            placeholder: (context, url) =>
                Container(color: Colors.grey.withValues(alpha: 0.1)),
            errorWidget: (context, url, error) =>
                _buildInitialsAvatar(context, title),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // For groups without avatars, maybe show a different style
    if (conversation!.type != .direct && (avatar == null || avatar.isEmpty)) {
      return _buildGroupAvatar(context);
    }

    return _buildInitialsAvatar(context, title);
  }

  Widget _buildGroupAvatar(BuildContext context) {
    final participants = conversation!.participants;
    final isDarkMode = Theme.of(context).brightness == .dark;

    if (participants.length >= 2) {
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              child: _buildParticipantCircle(
                context,
                participants[0],
                size * 0.7,
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: .all(
                    color: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
                    width: 2,
                  ),
                ),
                child: _buildParticipantCircle(
                  context,
                  participants[1],
                  size * 0.7,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _buildInitialsAvatar(context, conversation!.name ?? 'Group');
  }

  Widget _buildParticipantCircle(
    BuildContext context,
    ConversationMember member,
    double circleSize,
  ) {
    final avatar = member.user?.avatar ?? '';
    final name = (member.user?.firstName ?? 'U');

    if (avatar.isNotEmpty) {
      return Container(
        width: circleSize,
        height: circleSize,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: avatar,
            cacheManager: CacheManagers.messageCacheManager,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: circleSize,
      height: circleSize,
      decoration: const BoxDecoration(
        color: Color(0xFF0066FF),
        shape: BoxShape.circle,
      ),
      alignment: .center,
      child: Text(
        name.substring(0, 1).toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: circleSize * 0.4,
          fontWeight: .bold,
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(BuildContext context, String title) {
    final isDarkMode = Theme.of(context).brightness == .dark;
    final initials = title.substring(0, title.isNotEmpty ? 1 : 0).toUpperCase();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white10 : const Color(0xFFF3F4F6),
        shape: BoxShape.circle,
      ),
      alignment: .center,
      child: Text(
        initials,
        style: TextStyle(
          color: isDarkMode ? Colors.white70 : const Color(0xFF374151),
          fontWeight: .bold,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}
