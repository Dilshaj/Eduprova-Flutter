// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'team_profile.dart';
// import 'chat_avatar.dart';
// import '../../models/conversation_model.dart';
// import '../../models/message_model.dart';
// import '../../providers/messages_provider.dart';
// import '../../providers/chat_socket_provider.dart';
// import '../../../auth/providers/auth_provider.dart';

// class TeamChatScreen extends ConsumerStatefulWidget {
//   final ConversationModel? conversation;

//   const TeamChatScreen({super.key, this.conversation});

//   @override
//   ConsumerState<TeamChatScreen> createState() => _TeamChatScreenState();
// }

// class _TeamChatScreenState extends ConsumerState<TeamChatScreen> {
//   final textCtrl = TextEditingController();
//   final scrollCtrl = ScrollController();
//   final focusNode = FocusNode();
//   bool showMenu = false;

//   static const menuItems = [
//     {'icon': Icons.videocam_outlined, 'label': 'Create room'},
//     {'icon': Icons.search, 'label': 'Search in conversation'},
//     {'icon': Icons.person_add_outlined, 'label': 'Add participants'},
//     {'icon': Icons.push_pin_outlined, 'label': 'Pin conversation'},
//     {'icon': Icons.image_outlined, 'label': 'View shared media & files'},
//     {'icon': Icons.notifications_off_outlined, 'label': 'Mute notifications'},
//     {'icon': Icons.delete_outline, 'label': 'Clear chat'},
//     {'icon': Icons.flag_outlined, 'label': 'Report conversation'},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     if (widget.conversation != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ref
//             .read(chatSocketProvider.notifier)
//             .joinConversation(widget.conversation!.id);
//       });
//     }
//   }

//   @override
//   void dispose() {
//     if (widget.conversation != null) {
//       ref
//           .read(chatSocketProvider.notifier)
//           .leaveConversation(widget.conversation!.id);
//     }
//     textCtrl.dispose();
//     scrollCtrl.dispose();
//     focusNode.dispose();
//     super.dispose();
//   }

//   void sendMessage() {
//     if (textCtrl.text.trim().isEmpty || widget.conversation == null) return;
//     ref
//         .read(localMessagesProvider.notifier)
//         .sendMessage(widget.conversation!.id, textCtrl.text.trim());
//     textCtrl.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = ref.watch(authProvider);
//     final currentUserId = auth.user?.id ?? '';
//     final conversation = widget.conversation;

//     final isDarkMode = Theme.of(context).brightness == .dark;
//     final teamName =
//         conversation?.getDisplayTitle(currentUserId) ?? 'Design Team';
//     final participantCount = conversation?.participants.length ?? 0;

//     final messagesAsync = conversation != null
//         ? ref.watch(messagesFetcherProvider(conversation.id))
//         : const AsyncValue<List<MessageModel>>.data([]);

//     final localMessages = conversation != null
//         ? (ref.watch(localMessagesProvider)[conversation.id] ?? [])
//         : <MessageModel>[];

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: isDarkMode
//           ? const Color(0xFF0F172A)
//           : const Color(0xFFF9FAFB),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 // Header
//                 Container(
//                   color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
//                   padding: const .symmetric(horizontal: 8, vertical: 8),
//                   child: Row(
//                     children: [
//                       IconButton(
//                         onPressed: () => Navigator.pop(context),
//                         icon: Icon(
//                           Icons.arrow_back,
//                           color: isDarkMode
//                               ? Colors.white
//                               : const Color(0xFF111111),
//                         ),
//                       ),
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => TeamProfileScreen(
//                                   teamName: teamName,
//                                   teamAvatar: '',
//                                   participantsCount: participantCount,
//                                   conversation: conversation,
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Row(
//                             children: [
//                               ChatAvatar(
//                                 conversation: conversation,
//                                 currentUserId: currentUserId,
//                                 size: 40,
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: .start,
//                                   mainAxisSize: .min,
//                                   children: [
//                                     Text(
//                                       teamName,
//                                       style: GoogleFonts.inter(
//                                         fontSize: 16,
//                                         fontWeight: .bold,
//                                         color: isDarkMode
//                                             ? Colors.white
//                                             : const Color(0xFF111111),
//                                       ),
//                                       maxLines: 1,
//                                       overflow: .ellipsis,
//                                     ),
//                                     Text(
//                                       '$participantCount Participants',
//                                       style: GoogleFonts.inter(
//                                         fontSize: 12,
//                                         color: const Color(0xFF6B7280),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () {},
//                         icon: Icon(
//                           Icons.call_outlined,
//                           color: isDarkMode
//                               ? Colors.white70
//                               : const Color(0xFF111111),
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () {},
//                         icon: Icon(
//                           Icons.videocam_outlined,
//                           color: isDarkMode
//                               ? Colors.white70
//                               : const Color(0xFF111111),
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () => setState(() => showMenu = !showMenu),
//                         icon: Icon(
//                           Icons.more_vert,
//                           color: isDarkMode
//                               ? Colors.white70
//                               : const Color(0xFF111111),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Messages
//                 Expanded(
//                   child: messagesAsync.when(
//                     data: (fetched) {
//                       final fetchedIds = {for (final m in fetched) m.id};
//                       final combined = [
//                         ...localMessages.where(
//                           (m) => !fetchedIds.contains(m.id),
//                         ),
//                         ...fetched,
//                       ];

//                       return ListView.builder(
//                         controller: scrollCtrl,
//                         padding: const .symmetric(horizontal: 16, vertical: 16),
//                         itemCount: combined.length,
//                         itemBuilder: (ctx, i) {
//                           final msg = combined[i];
//                           final isMe = msg.senderId == currentUserId;

//                           // Look up sender in participants
//                           final senderMember = conversation?.participants
//                               .firstWhere(
//                                 (p) => p.userId == msg.senderId,
//                                 orElse: () => ConversationMember(
//                                   userId: msg.senderId,
//                                   role: 'member',
//                                   joinedAt: DateTime.now(),
//                                 ),
//                               );

//                           final senderName = senderMember?.user != null
//                               ? '${senderMember!.user!.firstName} ${senderMember.user!.lastName}'
//                               : 'Member';
//                           final senderAvatar = senderMember?.user?.avatar ?? '';

//                           return Padding(
//                             padding: const .only(bottom: 12),
//                             child: Row(
//                               crossAxisAlignment: .end,
//                               mainAxisAlignment: isMe
//                                   ? MainAxisAlignment.end
//                                   : MainAxisAlignment.start,
//                               children: [
//                                 if (!isMe) ...[
//                                   CircleAvatar(
//                                     radius: 16,
//                                     backgroundImage: senderAvatar.isNotEmpty
//                                         ? NetworkImage(senderAvatar)
//                                         : null,
//                                     child: senderAvatar.isEmpty
//                                         ? Text(
//                                             senderName
//                                                 .substring(0, 1)
//                                                 .toUpperCase(),
//                                           )
//                                         : null,
//                                   ),
//                                   const SizedBox(width: 8),
//                                 ],
//                                 Column(
//                                   crossAxisAlignment: isMe
//                                       ? CrossAxisAlignment.end
//                                       : CrossAxisAlignment.start,
//                                   children: [
//                                     if (!isMe)
//                                       Padding(
//                                         padding: const .only(
//                                           bottom: 4,
//                                           left: 4,
//                                         ),
//                                         child: Text(
//                                           senderName,
//                                           style: GoogleFonts.inter(
//                                             fontSize: 12,
//                                             fontWeight: .w600,
//                                             color: const Color(0xFF6B7280),
//                                           ),
//                                         ),
//                                       ),
//                                     Container(
//                                       constraints: BoxConstraints(
//                                         maxWidth:
//                                             MediaQuery.sizeOf(ctx).width * 0.65,
//                                       ),
//                                       padding: const .symmetric(
//                                         horizontal: 14,
//                                         vertical: 10,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: isMe
//                                             ? const Color(0xFF0066FF)
//                                             : (isDarkMode
//                                                   ? const Color(0xFF1E293B)
//                                                   : Colors.white),
//                                         borderRadius: .only(
//                                           topLeft: const Radius.circular(18),
//                                           topRight: const Radius.circular(18),
//                                           bottomLeft: Radius.circular(
//                                             isMe ? 18 : 4,
//                                           ),
//                                           bottomRight: Radius.circular(
//                                             isMe ? 4 : 18,
//                                           ),
//                                         ),
//                                         boxShadow: [
//                                           BoxShadow(
//                                             color: Colors.black.withValues(
//                                               alpha: 0.05,
//                                             ),
//                                             blurRadius: 4,
//                                           ),
//                                         ],
//                                       ),
//                                       child: Text(
//                                         msg.content ?? '',
//                                         style: GoogleFonts.inter(
//                                           fontSize: 15,
//                                           color: isMe
//                                               ? Colors.white
//                                               : (isDarkMode
//                                                     ? Colors.white
//                                                     : const Color(0xFF111111)),
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       '${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
//                                       style: GoogleFonts.inter(
//                                         fontSize: 11,
//                                         color: const Color(0xFF9CA3AF),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     },
//                     loading: () =>
//                         const Center(child: CircularProgressIndicator()),
//                     error: (err, stack) => Center(child: Text('Error: $err')),
//                   ),
//                 ),

//                 // Input
//                 Container(
//                   color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
//                   padding: const .fromLTRB(12, 10, 12, 10),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.sentiment_satisfied_outlined,
//                         size: 26,
//                         color: isDarkMode
//                             ? Colors.white70
//                             : const Color(0xFF8E8E93),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Container(
//                           height: 50,
//                           padding: const .symmetric(horizontal: 16),
//                           decoration: BoxDecoration(
//                             color: isDarkMode
//                                 ? const Color(0xFF0F172A)
//                                 : const Color(0xFFF3F4F6),
//                             borderRadius: .circular(25),
//                           ),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: TextField(
//                                   controller: textCtrl,
//                                   focusNode: focusNode,
//                                   decoration: const InputDecoration(
//                                     hintText: 'Type a message...',
//                                     hintStyle: TextStyle(
//                                       color: Color(0xFF8E8E93),
//                                     ),
//                                     border: InputBorder.none,
//                                   ),
//                                   style: GoogleFonts.inter(
//                                     color: isDarkMode
//                                         ? Colors.white
//                                         : Colors.black,
//                                   ),
//                                   onSubmitted: (_) => sendMessage(),
//                                 ),
//                               ),
//                               Icon(
//                                 Icons.attach_file,
//                                 size: 20,
//                                 color: isDarkMode
//                                     ? Colors.white70
//                                     : const Color(0xFF8E8E93),
//                               ),
//                               const SizedBox(width: 8),
//                               Icon(
//                                 Icons.mic_none,
//                                 size: 20,
//                                 color: isDarkMode
//                                     ? Colors.white70
//                                     : const Color(0xFF8E8E93),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       GestureDetector(
//                         onTap: sendMessage,
//                         child: Container(
//                           width: 48,
//                           height: 48,
//                           decoration: BoxDecoration(
//                             borderRadius: .circular(24),
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
//                             ),
//                           ),
//                           alignment: .center,
//                           child: const Icon(
//                             Icons.send,
//                             size: 20,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             // Context menu
//             if (showMenu)
//               Positioned(
//                 top: 60,
//                 right: 16,
//                 child: Material(
//                   color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
//                   borderRadius: .circular(16),
//                   elevation: 8,
//                   child: SizedBox(
//                     width: 260,
//                     child: Column(
//                       children: menuItems
//                           .map(
//                             (item) => InkWell(
//                               onTap: () => setState(() => showMenu = false),
//                               child: Padding(
//                                 padding: const .symmetric(
//                                   horizontal: 16,
//                                   vertical: 14,
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                       item['icon'] as IconData,
//                                       size: 20,
//                                       color: isDarkMode
//                                           ? Colors.white70
//                                           : const Color(0xFF4B5563),
//                                     ),
//                                     const SizedBox(width: 12),
//                                     Text(
//                                       item['label'] as String,
//                                       style: GoogleFonts.inter(
//                                         fontSize: 14,
//                                         fontWeight: .w500,
//                                         color: isDarkMode
//                                             ? Colors.white
//                                             : const Color(0xFF374151),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           )
//                           .toList(),
//                     ),
//                   ),
//                 ),
//               ),

//             if (showMenu)
//               Positioned.fill(
//                 child: GestureDetector(
//                   onTap: () => setState(() => showMenu = false),
//                   behavior: HitTestBehavior.translucent,
//                   child: const SizedBox.expand(),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
