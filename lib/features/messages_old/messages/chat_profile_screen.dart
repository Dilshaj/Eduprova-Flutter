import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/image_cache_manager.dart';
import '../../auth/providers/auth_provider.dart';
import '../messages-home/widgets/chat_avatar.dart';
import '../models/conversation_model.dart';
import '../providers/messages_provider.dart';
import '../widgets/participant_picker_screen.dart';
import '../models/search_user_model.dart';
import '../repository/messages_repository.dart';

class ChatProfileScreen extends ConsumerStatefulWidget {
  final ConversationModel conversation;

  const ChatProfileScreen({super.key, required this.conversation});

  @override
  ConsumerState<ChatProfileScreen> createState() => _ChatProfileScreenState();
}

class _ChatProfileScreenState extends ConsumerState<ChatProfileScreen> {
  final MessagesRepository _repository = MessagesRepository();
  late ConversationModel _conversation;
  bool _isAddingParticipants = false;

  @override
  void initState() {
    super.initState();
    _conversation = widget.conversation;
  }

  bool get _isGroup => _conversation.type != ConversationType.direct;

  bool get _canManageParticipants {
    if (!_isGroup) return false;
    final currentUserId = ref.read(authProvider).user?.id ?? '';
    return _conversation.participants.any(
      (participant) =>
          participant.userId == currentUserId &&
          (participant.role == 'admin' || _conversation.createdBy == currentUserId),
    );
  }

  Future<void> _addParticipants() async {
    if (_isAddingParticipants || !_canManageParticipants) return;

    final selected = await Navigator.of(context).push<List<SearchUserModel>>(
      MaterialPageRoute(
        builder: (_) => const ParticipantPickerScreen(
          title: 'Add Participants',
          submitLabel: 'Add',
        ),
      ),
    );

    if (!mounted || selected == null || selected.isEmpty) return;

    final existingIds = _conversation.participants
        .map((participant) => participant.userId)
        .toSet();
    final userIds = selected
        .map((user) => user.id)
        .where((id) => !existingIds.contains(id))
        .toList();

    if (userIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All selected users are already in this chat')),
      );
      return;
    }

    setState(() => _isAddingParticipants = true);
    final updated = await _repository.addParticipants(_conversation.id, userIds);
    if (!mounted) return;
    setState(() => _isAddingParticipants = false);

    if (updated == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to add participants')),
      );
      return;
    }

    setState(() => _conversation = updated);
    ref.read(conversationsProvider.notifier).addOrUpdateConversation(updated);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Participants added')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final currentUserId = ref.watch(authProvider).user?.id ?? '';
    final title = _conversation.getDisplayTitle(currentUserId);
    final avatar = _conversation.getDisplayAvatar(currentUserId);
    final isFavorite = ref.watch(
      favoriteConversationIdsProvider.select((ids) => ids.contains(_conversation.id)),
    );
    final messages = ref.watch(combinedMessagesProvider(_conversation.id));
    final media = [
      for (final message in messages)
        for (final attachment in message.attachments)
          if (attachment.type == 'image' && attachment.url.isNotEmpty) attachment.url,
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(_isGroup ? 'Group Info' : 'Chat Profile'),
        actions: [
          IconButton(
            onPressed: () => ref
                .read(favoriteConversationIdsProvider.notifier)
                .toggle(_conversation.id),
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isFavorite ? Colors.amber.shade600 : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Center(
            child: Column(
              children: [
                ChatAvatar(
                  conversation: _conversation,
                  currentUserId: currentUserId,
                  size: 104,
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  _isGroup
                      ? '${_conversation.participants.length} participants'
                      : 'Shared media: ${media.length}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDarkMode
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                  ),
                ),
                if ((_conversation.description ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    _conversation.description!.trim(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDarkMode
                          ? const Color(0xFFD1D5DB)
                          : const Color(0xFF475569),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildActionTile(
            icon: isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
            title: isFavorite ? 'Remove from favourites' : 'Add to favourites',
            onTap: () => ref
                .read(favoriteConversationIdsProvider.notifier)
                .toggle(_conversation.id),
          ),
          if (_canManageParticipants)
            _buildActionTile(
              icon: _isAddingParticipants
                  ? Icons.hourglass_top_rounded
                  : Icons.person_add_alt_1_rounded,
              title: 'Add participants',
              onTap: _isAddingParticipants ? null : _addParticipants,
            ),
          const SizedBox(height: 24),
          _buildSectionTitle('Shared Media'),
          const SizedBox(height: 12),
          if (media.isEmpty)
            _buildEmptyCard('No media shared in this chat yet.')
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: media.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: media[index],
                    cacheManager: CacheManagers.messageCacheManager,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          if (_isGroup) ...[
            const SizedBox(height: 24),
            _buildSectionTitle('Participants'),
            const SizedBox(height: 12),
            for (final participant in _conversation.participants)
              _ParticipantTile(participant: participant),
          ],
          if (!_isGroup && avatar != null && avatar.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionTitle('Photo'),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: avatar,
                cacheManager: CacheManagers.messageCacheManager,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildEmptyCard(String text) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(text),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final ConversationMember participant;

  const _ParticipantTile({required this.participant});

  @override
  Widget build(BuildContext context) {
    final name = participant.user != null
        ? '${participant.user!.firstName} ${participant.user!.lastName}'.trim()
        : 'Participant';
    final avatar = participant.user?.avatar;
    final role = participant.role == 'admin' ? 'Admin' : 'Member';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: avatar != null && avatar.isNotEmpty
              ? CachedNetworkImageProvider(
                  avatar,
                  cacheManager: CacheManagers.messageCacheManager,
                )
              : null,
          child: avatar == null || avatar.isEmpty
              ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?')
              : null,
        ),
        title: Text(name.isEmpty ? 'Participant' : name),
        subtitle: Text(role),
      ),
    );
  }
}
