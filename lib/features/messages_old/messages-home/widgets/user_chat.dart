// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'chat_avatar.dart';
// import 'user_profile.dart';
// import '../../models/conversation_model.dart';
// import '../../models/message_model.dart';
// import '../../providers/messages_provider.dart';
// import '../../providers/chat_socket_provider.dart';
// import '../../../auth/providers/auth_provider.dart';

// class UserChatScreen extends ConsumerStatefulWidget {
//   final ConversationModel? conversation;
//   final String? userName;
//   final String? userAvatar;
//   final String? userStatus;

//   const UserChatScreen({
//     super.key,
//     this.conversation,
//     this.userName,
//     this.userAvatar,
//     this.userStatus,
//   });

//   @override
//   ConsumerState<UserChatScreen> createState() => _UserChatScreenState();
// }

// class _UserChatScreenState extends ConsumerState<UserChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final FocusNode _focusNode = FocusNode();
//   final ScrollController _scrollController = ScrollController();
//   bool showMenu = false;

//   // Selection & Reply State
//   final Set<String> _selectedMessageIds = {};
//   MessageModel? _replyingMessage;
//   bool _showReactionOverlay = false;
//   String? _reactionMessageId;

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
//     _messageController.dispose();
//     _focusNode.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _sendMessage() {
//     if (_messageController.text.trim().isEmpty || widget.conversation == null) {
//       return;
//     }

//     ref
//         .read(localMessagesProvider.notifier)
//         .sendMessage(
//           widget.conversation!.id,
//           _messageController.text.trim(),
//           replyTo: _replyingMessage?.id,
//         );
//     _messageController.clear();
//     setState(() {
//       _replyingMessage = null;
//     });
//   }

//   void _toggleSelection(String messageId) {
//     setState(() {
//       if (_selectedMessageIds.contains(messageId)) {
//         _selectedMessageIds.remove(messageId);
//       } else {
//         _selectedMessageIds.add(messageId);
//       }
//       if (_selectedMessageIds.isEmpty) {
//         _showReactionOverlay = false;
//         _reactionMessageId = null;
//       } else if (_selectedMessageIds.length == 1) {
//         _reactionMessageId = _selectedMessageIds.first;
//       } else {
//         _showReactionOverlay = false;
//       }
//     });
//   }

//   void _cancelSelection() {
//     setState(() {
//       _selectedMessageIds.clear();
//       _showReactionOverlay = false;
//       _reactionMessageId = null;
//     });
//   }

//   void _addReaction(String messageId, String emoji) {
//     if (widget.conversation == null) return;
//     ref.read(messagesRepositoryProvider).addReaction(messageId, emoji);
//     // Real-time update should happen via socket, but we can also update locally
//     ref.read(localMessagesProvider.notifier).updateReactions(
//       widget.conversation!.id,
//       messageId,
//       [
//         {'emoji': emoji, 'userId': ref.read(authProvider).user?.id ?? ''},
//       ],
//     );
//   }

//   void _onReply(MessageModel message) {
//     setState(() {
//       _replyingMessage = message;
//       _cancelSelection();
//     });
//     _focusNode.requestFocus();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = ref.watch(authProvider);
//     final currentUserId = auth.user?.id ?? '';
//     final conversation = widget.conversation;

//     final userName =
//         conversation?.getDisplayTitle(currentUserId) ??
//         widget.userName ??
//         'User';
//     final userStatus = widget.userStatus ?? 'online';
//     final isDarkMode = Theme.of(context).brightness == .dark;

//     final messagesAsync = conversation != null
//         ? ref.watch(messagesFetcherProvider(conversation.id))
//         : const AsyncValue<List<MessageModel>>.data([]);

//     final localMessages = conversation != null
//         ? (ref.watch(localMessagesProvider)[conversation.id] ?? [])
//         : <MessageModel>[];

//     final isSelectionMode = _selectedMessageIds.isNotEmpty;

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
//                 // Header / App Bar
//                 _buildHeader(
//                   context,
//                   isDarkMode,
//                   userName,
//                   userStatus,
//                   conversation,
//                   currentUserId,
//                   isSelectionMode,
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
//                         controller: _scrollController,
//                         padding: const .symmetric(horizontal: 16, vertical: 16),
//                         reverse: true,
//                         itemCount: combined.length,
//                         itemBuilder: (ctx, i) {
//                           final msg = combined[i];
//                           final isMe = msg.senderId == currentUserId;
//                           final isSelected = _selectedMessageIds.contains(
//                             msg.id,
//                           );

//                           return _buildMessageBubble(
//                             ctx,
//                             msg,
//                             isMe,
//                             isDarkMode,
//                             isSelected,
//                             isSelectionMode,
//                             conversation,
//                             currentUserId,
//                           );
//                         },
//                       );
//                     },
//                     loading: () =>
//                         const Center(child: CircularProgressIndicator()),
//                     error: (err, stack) => Center(child: Text('Error: $err')),
//                   ),
//                 ),

//                 // Input Area with Reply Preview
//                 _buildInputArea(isDarkMode),
//               ],
//             ),

//             // Reaction Overlay for single selection
//             if (_showReactionOverlay && _reactionMessageId != null)
//               _buildReactionOverlay(context, isDarkMode),

//             // Context Menu
//             if (showMenu) _buildContextMenu(isDarkMode),

//             // Menu Backdrop
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

//   Widget _buildHeader(
//     BuildContext context,
//     bool isDarkMode,
//     String userName,
//     String userStatus,
//     ConversationModel? conversation,
//     String currentUserId,
//     bool isSelectionMode,
//   ) {
//     if (isSelectionMode) {
//       return Container(
//         color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
//         padding: const .symmetric(horizontal: 8, vertical: 8),
//         child: Row(
//           children: [
//             IconButton(
//               onPressed: _cancelSelection,
//               icon: Icon(
//                 Icons.close,
//                 color: isDarkMode ? Colors.white : Colors.black,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Text(
//               '${_selectedMessageIds.length} selected',
//               style: GoogleFonts.inter(
//                 fontSize: 18,
//                 fontWeight: .bold,
//                 color: isDarkMode ? Colors.white : Colors.black,
//               ),
//             ),
//             const Spacer(),
//             if (_selectedMessageIds.length == 1) ...[
//               IconButton(
//                 onPressed: () {
//                   setState(() => _showReactionOverlay = !_showReactionOverlay);
//                 },
//                 icon: Icon(
//                   Icons.add_reaction_outlined,
//                   color: isDarkMode ? Colors.white70 : Colors.black54,
//                 ),
//               ),
//               IconButton(
//                 onPressed: () {
//                   final msgId = _selectedMessageIds.first;
//                   final conversationId = widget.conversation?.id;
//                   if (conversationId != null) {
//                     final messages = ref.read(
//                       combinedMessagesProvider(conversationId),
//                     );
//                     final msg = messages.firstWhere((m) => m.id == msgId);
//                     _onReply(msg);
//                   }
//                 },
//                 icon: Icon(
//                   Icons.reply,
//                   color: isDarkMode ? Colors.white70 : Colors.black54,
//                 ),
//               ),
//             ],
//             IconButton(
//               onPressed: () {
//                 // Forward logic placeholder
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Forwarding not implemented')),
//                 );
//                 _cancelSelection();
//               },
//               icon: Icon(
//                 Icons.forward,
//                 color: isDarkMode ? Colors.white70 : Colors.black54,
//               ),
//             ),
//             IconButton(
//               onPressed: () {
//                 // Delete logic placeholder
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Deleting not implemented')),
//                 );
//                 _cancelSelection();
//               },
//               icon: Icon(
//                 Icons.delete_outline,
//                 color: isDarkMode ? Colors.white70 : Colors.black54,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return Container(
//       color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
//       padding: const .symmetric(horizontal: 8, vertical: 8),
//       child: Row(
//         children: [
//           IconButton(
//             onPressed: () => Navigator.pop(context),
//             icon: Icon(
//               Icons.arrow_back,
//               color: isDarkMode ? Colors.white : const Color(0xFF111111),
//             ),
//           ),
//           Expanded(
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => UserProfileScreen(
//                       userName: userName,
//                       userAvatar: '',
//                       userStatus: userStatus,
//                       conversation: conversation,
//                     ),
//                   ),
//                 );
//               },
//               child: Row(
//                 children: [
//                   ChatAvatar(
//                     conversation: conversation,
//                     currentUserId: currentUserId,
//                     size: 40,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: .start,
//                       mainAxisSize: .min,
//                       children: [
//                         Text(
//                           userName,
//                           style: GoogleFonts.inter(
//                             fontSize: 16,
//                             fontWeight: .bold,
//                             color: isDarkMode
//                                 ? Colors.white
//                                 : const Color(0xFF111111),
//                           ),
//                           maxLines: 1,
//                           overflow: .ellipsis,
//                         ),
//                         Text(
//                           userStatus == 'online' ? 'Active now' : 'Away',
//                           style: GoogleFonts.inter(
//                             fontSize: 12,
//                             color: userStatus == 'online'
//                                 ? const Color(0xFF10B981)
//                                 : const Color(0xFF6B7280),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           IconButton(
//             onPressed: () {},
//             icon: Icon(
//               Icons.call_outlined,
//               color: isDarkMode ? Colors.white70 : const Color(0xFF111111),
//             ),
//           ),
//           IconButton(
//             onPressed: () {},
//             icon: Icon(
//               Icons.videocam_outlined,
//               color: isDarkMode ? Colors.white70 : const Color(0xFF111111),
//             ),
//           ),
//           IconButton(
//             onPressed: () => setState(() => showMenu = !showMenu),
//             icon: Icon(
//               Icons.more_vert,
//               color: isDarkMode ? Colors.white70 : const Color(0xFF111111),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageBubble(
//     BuildContext context,
//     MessageModel msg,
//     bool isMe,
//     bool isDarkMode,
//     bool isSelected,
//     bool isSelectionMode,
//     ConversationModel? conversation,
//     String currentUserId,
//   ) {
//     return GestureDetector(
//       onLongPress: () => _toggleSelection(msg.id),
//       onTap: () {
//         if (isSelectionMode) {
//           _toggleSelection(msg.id);
//         }
//       },
//       child: Stack(
//         children: [
//           if (isSelected)
//             Positioned.fill(
//               child: Container(
//                 color: const Color(0xFF0066FF).withValues(alpha: 0.1),
//               ),
//             ),
//           _SwipeToReply(
//             onReply: () => _onReply(msg),
//             child: Padding(
//               padding: const .only(bottom: 12, left: 16, right: 16),
//               child: Row(
//                 crossAxisAlignment: .end,
//                 mainAxisAlignment: isMe
//                     ? MainAxisAlignment.end
//                     : MainAxisAlignment.start,
//                 children: [
//                   if (!isMe) ...[
//                     ChatAvatar(
//                       conversation: conversation,
//                       currentUserId: currentUserId,
//                       size: 28,
//                     ),
//                     const SizedBox(width: 8),
//                   ],
//                   Column(
//                     crossAxisAlignment: isMe
//                         ? CrossAxisAlignment.end
//                         : CrossAxisAlignment.start,
//                     children: [
//                       if (msg.replyToMessage != null)
//                         _buildReplyPreview(
//                           msg.replyToMessage!,
//                           isDarkMode,
//                           isMe,
//                         ),
//                       Container(
//                         constraints: BoxConstraints(
//                           maxWidth: MediaQuery.sizeOf(context).width * 0.7,
//                         ),
//                         padding: const .symmetric(horizontal: 14, vertical: 10),
//                         decoration: BoxDecoration(
//                           color: isMe
//                               ? const Color(0xFF0066FF)
//                               : (isDarkMode
//                                     ? const Color(0xFF1E293B)
//                                     : Colors.white),
//                           borderRadius: .only(
//                             topLeft: const Radius.circular(18),
//                             topRight: const Radius.circular(18),
//                             bottomLeft: Radius.circular(isMe ? 18 : 4),
//                             bottomRight: Radius.circular(isMe ? 4 : 18),
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withValues(alpha: 0.05),
//                               blurRadius: 4,
//                             ),
//                           ],
//                         ),
//                         child: Text(
//                           msg.content ?? '',
//                           style: GoogleFonts.inter(
//                             fontSize: 15,
//                             color: isMe
//                                 ? Colors.white
//                                 : (isDarkMode
//                                       ? Colors.white
//                                       : const Color(0xFF111111)),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisSize: .min,
//                         children: [
//                           Text(
//                             _formatTime(msg.createdAt),
//                             style: GoogleFonts.inter(
//                               fontSize: 11,
//                               color: const Color(0xFF9CA3AF),
//                             ),
//                           ),
//                           if (isMe) ...[
//                             const SizedBox(width: 4),
//                             Icon(
//                               Icons.done_all,
//                               size: 14,
//                               color: const Color(0xFF0066FF),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReplyPreview(
//     Map<String, dynamic> reply,
//     bool isDarkMode,
//     bool isMe,
//   ) {
//     return Container(
//       margin: const .only(bottom: 4),
//       padding: const .all(8),
//       decoration: BoxDecoration(
//         color: isDarkMode
//             ? Colors.white.withValues(alpha: 0.05)
//             : Colors.black.withValues(alpha: 0.05),
//         borderRadius: .circular(8),
//         border: const Border(
//           left: BorderSide(color: Color(0xFF0066FF), width: 4),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: .start,
//         children: [
//           Text(
//             reply['senderName'] ?? 'Replied to message',
//             style: GoogleFonts.inter(
//               fontSize: 12,
//               fontWeight: .bold,
//               color: const Color(0xFF0066FF),
//             ),
//           ),
//           Text(
//             reply['content'] ?? '',
//             maxLines: 1,
//             overflow: .ellipsis,
//             style: GoogleFonts.inter(
//               fontSize: 12,
//               color: isDarkMode ? Colors.white70 : Colors.black54,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInputArea(bool isDarkMode) {
//     return Column(
//       mainAxisSize: .min,
//       children: [
//         if (_replyingMessage != null)
//           Container(
//             padding: const .symmetric(horizontal: 16, vertical: 8),
//             color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
//             child: Row(
//               children: [
//                 const Icon(Icons.reply, size: 20, color: Color(0xFF0066FF)),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: .start,
//                     children: [
//                       Text(
//                         'Replying to',
//                         style: GoogleFonts.inter(
//                           fontSize: 12,
//                           fontWeight: .bold,
//                           color: const Color(0xFF0066FF),
//                         ),
//                       ),
//                       Text(
//                         _replyingMessage?.content ?? '',
//                         maxLines: 1,
//                         overflow: .ellipsis,
//                         style: GoogleFonts.inter(
//                           fontSize: 14,
//                           color: isDarkMode ? Colors.white70 : Colors.black54,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => setState(() => _replyingMessage = null),
//                   icon: const Icon(Icons.close, size: 20),
//                 ),
//               ],
//             ),
//           ),
//         Container(
//           color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
//           padding: .fromLTRB(12, 10, 12, 10),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.sentiment_satisfied_outlined,
//                 size: 26,
//                 color: isDarkMode ? Colors.white70 : const Color(0xFF8E8E93),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Container(
//                   height: 50,
//                   padding: const .symmetric(horizontal: 16),
//                   decoration: BoxDecoration(
//                     color: isDarkMode
//                         ? const Color(0xFF0F172A)
//                         : const Color(0xFFF3F4F6),
//                     borderRadius: .circular(25),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _messageController,
//                           focusNode: _focusNode,
//                           decoration: InputDecoration.collapsed(
//                             hintText: 'Type a message...',
//                             hintStyle: GoogleFonts.inter(
//                               color: const Color(0xFF8E8E93),
//                             ),
//                           ),
//                           style: GoogleFonts.inter(
//                             color: isDarkMode ? Colors.white : Colors.black,
//                           ),
//                         ),
//                       ),
//                       Icon(
//                         Icons.attach_file,
//                         size: 20,
//                         color: isDarkMode
//                             ? Colors.white70
//                             : const Color(0xFF8E8E93),
//                       ),
//                       const SizedBox(width: 8),
//                       Icon(
//                         Icons.mic_none,
//                         size: 20,
//                         color: isDarkMode
//                             ? Colors.white70
//                             : const Color(0xFF8E8E93),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               GestureDetector(
//                 onTap: _sendMessage,
//                 child: Container(
//                   width: 48,
//                   height: 48,
//                   decoration: BoxDecoration(
//                     borderRadius: .circular(24),
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
//                     ),
//                   ),
//                   alignment: .center,
//                   child: const Icon(Icons.send, size: 20, color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildReactionOverlay(BuildContext context, bool isDarkMode) {
//     return Positioned(
//       top:
//           100, // This should ideally be calculated based on the message position
//       left: 16,
//       right: 16,
//       child: Center(
//         child: Container(
//           padding: const .symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(
//             color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
//             borderRadius: .circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.1),
//                 blurRadius: 10,
//                 spreadRadius: 2,
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisSize: .min,
//             children: ['❤️', '👍', '😂', '😮', '😢', '🔥'].map((emoji) {
//               return GestureDetector(
//                 onTap: () {
//                   if (_reactionMessageId != null) {
//                     _addReaction(_reactionMessageId!, emoji);
//                   }
//                   _cancelSelection();
//                 },
//                 child: Padding(
//                   padding: const .symmetric(horizontal: 8),
//                   child: Text(emoji, style: const TextStyle(fontSize: 24)),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildContextMenu(bool isDarkMode) {
//     final menuItems = [
//       {'icon': Icons.info_outline, 'label': 'View Profile'},
//       {'icon': Icons.notifications_outlined, 'label': 'Mute'},
//       {'icon': Icons.search, 'label': 'Search Chat'},
//       {'icon': Icons.block_flipped, 'label': 'Block', 'isRed': true},
//     ];

//     return Positioned(
//       top: 60,
//       right: 16,
//       child: Material(
//         color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
//         borderRadius: .circular(16),
//         elevation: 8,
//         child: SizedBox(
//           width: 200,
//           child: Column(
//             children: menuItems.map((item) {
//               final isRed = item['isRed'] == true;
//               return InkWell(
//                 onTap: () => setState(() => showMenu = false),
//                 child: Padding(
//                   padding: const .symmetric(horizontal: 16, vertical: 14),
//                   child: Row(
//                     children: [
//                       Icon(
//                         item['icon'] as IconData,
//                         size: 20,
//                         color: isRed
//                             ? Colors.redAccent
//                             : (isDarkMode
//                                   ? Colors.white70
//                                   : const Color(0xFF4B5563)),
//                       ),
//                       const SizedBox(width: 12),
//                       Text(
//                         item['label'] as String,
//                         style: GoogleFonts.inter(
//                           fontSize: 14,
//                           fontWeight: .w500,
//                           color: isRed
//                               ? Colors.redAccent
//                               : (isDarkMode
//                                     ? Colors.white
//                                     : const Color(0xFF374151)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }

//   String _formatTime(DateTime time) {
//     return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
//   }
// }

// class _SwipeToReply extends StatefulWidget {
//   final Widget child;
//   final VoidCallback onReply;

//   const _SwipeToReply({required this.child, required this.onReply});

//   @override
//   State<_SwipeToReply> createState() => _SwipeToReplyState();
// }

// class _SwipeToReplyState extends State<_SwipeToReply> {
//   double _dragOffset = 0;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onHorizontalDragUpdate: (details) {
//         if (details.delta.dx > 0) {
//           setState(() {
//             _dragOffset = (details.delta.dx + _dragOffset).clamp(0, 100);
//           });
//         }
//       },
//       onHorizontalDragEnd: (details) {
//         if (_dragOffset > 50) {
//           widget.onReply();
//         }
//         setState(() {
//           _dragOffset = 0;
//         });
//       },
//       child: Stack(
//         alignment: Alignment.centerLeft,
//         children: [
//           Transform.translate(
//             offset: Offset(_dragOffset, 0),
//             child: widget.child,
//           ),
//           if (_dragOffset > 0)
//             Positioned(
//               left: _dragOffset / 2 - 20,
//               child: Opacity(
//                 opacity: (_dragOffset / 50).clamp(0, 1),
//                 child: const Icon(Icons.reply, color: Color(0xFF0066FF)),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
