// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../widgets/messages_background.dart';
// import '../../models/conversation_model.dart';
// import 'chat_avatar.dart';

// class UserProfileScreen extends StatelessWidget {
//   final String userName;
//   final String userAvatar;
//   final String userStatus;
//   final ConversationModel? conversation;

//   const UserProfileScreen({
//     super.key,
//     required this.userName,
//     required this.userAvatar,
//     required this.userStatus,
//     this.conversation,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == .dark;

//     return MessagesBackground(
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           leading: IconButton(
//             icon: Icon(
//               Icons.arrow_back,
//               color: isDarkMode ? Colors.white : Colors.black,
//             ),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: Text(
//             'Profile',
//             style: GoogleFonts.inter(
//               color: isDarkMode ? Colors.white : Colors.black,
//               fontWeight: .bold,
//             ),
//           ),
//           centerTitle: true,
//         ),
//         body: SingleChildScrollView(
//           padding: const .symmetric(horizontal: 24),
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
//               // Profile Image
//               Center(
//                 child: Stack(
//                   children: [
//                     Container(
//                       padding: const .all(4),
//                       decoration: const BoxDecoration(
//                         shape: BoxShape.circle,
//                         gradient: LinearGradient(
//                           colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
//                         ),
//                       ),
//                       child: conversation != null
//                           ? ChatAvatar(
//                               conversation: conversation,
//                               currentUserId:
//                                   '', // Empty means show the other user's avatar or group avatar
//                               size: 120,
//                             )
//                           : CircleAvatar(
//                               radius: 60,
//                               backgroundImage: NetworkImage(
//                                 userAvatar.isNotEmpty
//                                     ? userAvatar
//                                     : 'https://i.pravatar.cc/120',
//                               ),
//                             ),
//                     ),
//                     Positioned(
//                       bottom: 8,
//                       right: 8,
//                       child: Container(
//                         width: 24,
//                         height: 24,
//                         decoration: BoxDecoration(
//                           color: userStatus == 'online'
//                               ? Colors.green
//                               : Colors.orange,
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: isDarkMode
//                                 ? const Color(0xFF1E293B)
//                                 : Colors.white,
//                             width: 3,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 userName,
//                 style: GoogleFonts.inter(
//                   fontSize: 24,
//                   fontWeight: .bold,
//                   color: isDarkMode ? Colors.white : Colors.black,
//                 ),
//               ),
//               Text(
//                 userStatus == 'online' ? 'Active Now' : 'Away',
//                 style: GoogleFonts.inter(
//                   fontSize: 16,
//                   color: userStatus == 'online' ? Colors.green : Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 32),

//               // Action Buttons
//               Row(
//                 mainAxisAlignment: .spaceEvenly,
//                 children: [
//                   _buildActionIcon(
//                     Icons.message_outlined,
//                     'Message',
//                     isDarkMode,
//                   ),
//                   _buildActionIcon(
//                     Icons.videocam_outlined,
//                     'Video',
//                     isDarkMode,
//                   ),
//                   _buildActionIcon(Icons.call_outlined, 'Call', isDarkMode),
//                   _buildActionIcon(Icons.search, 'Search', isDarkMode),
//                 ],
//               ),

//               const SizedBox(height: 40),

//               // Details
//               _buildSectionHeader('Details', isDarkMode),
//               _buildDetailItem(
//                 Icons.email_outlined,
//                 'Email',
//                 '${userName.toLowerCase().replaceAll(' ', '.')}@eduprova.com',
//                 isDarkMode,
//               ),
//               _buildDetailItem(
//                 Icons.phone_outlined,
//                 'Phone',
//                 '+91 98765 43210',
//                 isDarkMode,
//               ),
//               _buildDetailItem(
//                 Icons.location_on_outlined,
//                 'Location',
//                 'Hyderabad, India',
//                 isDarkMode,
//               ),

//               const SizedBox(height: 24),
//               _buildSectionHeader('Shared Media', isDarkMode),
//               const SizedBox(height: 12),
//               SizedBox(
//                 height: 100,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: 5,
//                   itemBuilder: (context, index) {
//                     return Container(
//                       width: 100,
//                       margin: const .only(right: 12),
//                       decoration: BoxDecoration(
//                         borderRadius: .circular(12),
//                         image: DecorationImage(
//                           image: NetworkImage(
//                             'https://picsum.photos/200/200?random=${index + 10}',
//                           ),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               const SizedBox(height: 40),
//               // More Actions
//               _buildListTile(
//                 Icons.notifications_outlined,
//                 'Mute Notifications',
//                 isDarkMode,
//                 isRed: false,
//               ),
//               _buildListTile(
//                 Icons.block_flipped,
//                 'Block $userName',
//                 isDarkMode,
//                 isRed: true,
//               ),
//               _buildListTile(
//                 Icons.report_problem_outlined,
//                 'Report Contact',
//                 isDarkMode,
//                 isRed: true,
//               ),
//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildActionIcon(IconData icon, String label, bool isDarkMode) {
//     return Column(
//       children: [
//         Container(
//           padding: const .all(12),
//           decoration: BoxDecoration(
//             color: isDarkMode
//                 ? Colors.white.withValues(alpha: 0.1)
//                 : Colors.black.withValues(alpha: 0.05),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, color: isDarkMode ? Colors.white : Colors.black),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           style: GoogleFonts.inter(
//             fontSize: 12,
//             color: isDarkMode ? Colors.white70 : Colors.black54,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSectionHeader(String title, bool isDarkMode) {
//     return Align(
//       alignment: .centerLeft,
//       child: Text(
//         title,
//         style: GoogleFonts.inter(
//           fontSize: 18,
//           fontWeight: .bold,
//           color: isDarkMode ? Colors.white : Colors.black,
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailItem(
//     IconData icon,
//     String label,
//     String value,
//     bool isDarkMode,
//   ) {
//     return Padding(
//       padding: const .only(top: 16),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: Colors.blueAccent),
//           const SizedBox(width: 16),
//           Column(
//             crossAxisAlignment: .start,
//             children: [
//               Text(
//                 label,
//                 style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
//               ),
//               Text(
//                 value,
//                 style: GoogleFonts.inter(
//                   fontSize: 15,
//                   fontWeight: .w500,
//                   color: isDarkMode ? Colors.white : Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildListTile(
//     IconData icon,
//     String label,
//     bool isDarkMode, {
//     required bool isRed,
//   }) {
//     return ListTile(
//       contentPadding: .zero,
//       leading: Icon(
//         icon,
//         color: isRed
//             ? Colors.redAccent
//             : (isDarkMode ? Colors.white70 : Colors.black54),
//       ),
//       title: Text(
//         label,
//         style: GoogleFonts.inter(
//           color: isRed
//               ? Colors.redAccent
//               : (isDarkMode ? Colors.white : Colors.black),
//           fontSize: 16,
//         ),
//       ),
//       trailing: const Icon(Icons.chevron_right, size: 20),
//       onTap: () {},
//     );
//   }
// }
