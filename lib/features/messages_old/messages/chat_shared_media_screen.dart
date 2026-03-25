import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/messages_provider.dart';
import 'image_preview_screen.dart';

class ChatSharedMediaScreen extends ConsumerStatefulWidget {
  final dynamic conversation;

  const ChatSharedMediaScreen({super.key, required this.conversation});

  @override
  ConsumerState<ChatSharedMediaScreen> createState() =>
      _ChatSharedMediaScreenState();
}

class _ChatSharedMediaScreenState extends ConsumerState<ChatSharedMediaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    final messages = ref.watch(
      combinedMessagesProvider(widget.conversation.id),
    );
    final mediaAttachments = messages
        .where((m) => m.attachments.isNotEmpty)
        .expand((m) => m.attachments)
        .where((a) => a.type == 'image' || a.type == 'video')
        .toList();

    final docAttachments = messages
        .where((m) => m.attachments.isNotEmpty)
        .expand((m) => m.attachments)
        .where((a) => a.type == 'file' || a.type == 'document')
        .toList();

    final linkAttachments = messages
        .where((m) => m.attachments.isNotEmpty)
        .expand((m) => m.attachments)
        .where((a) => a.type == 'link')
        .toList();

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
          'Media, Links, and Docs',
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0066FF),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF0066FF),
          tabs: const [
            Tab(text: 'Media'),
            Tab(text: 'Docs'),
            Tab(text: 'Links'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          mediaAttachments.isEmpty
              ? _buildEmptyState('No media shared yet', isDarkMode)
              : GridView.builder(
                  padding: const EdgeInsets.all(4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: mediaAttachments.length,
                  itemBuilder: (context, index) {
                    final media = mediaAttachments[index];
                    return GestureDetector(
                      onTap: () {
                        final imageUrls = mediaAttachments
                            .where((a) => a.type == 'image')
                            .map((a) => a.url)
                            .toList();
                        final clickedIndex = imageUrls.indexOf(media.url);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ImagePreviewScreen(
                              imageUrls: imageUrls.isEmpty
                                  ? [media.url]
                                  : imageUrls,
                              initialIndex: clickedIndex >= 0
                                  ? clickedIndex
                                  : 0,
                              heroTag: 'shared_media_${media.url}',
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: 'shared_media_${media.url}',
                        child: CachedNetworkImage(
                          imageUrl: media.url,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[200],
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[200],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
          docAttachments.isEmpty
              ? _buildEmptyState('No documents shared yet', isDarkMode)
              : ListView.builder(
                  itemCount: docAttachments.length,
                  itemBuilder: (context, index) {
                    final doc = docAttachments[index];
                    return ListTile(
                      leading: Icon(Icons.insert_drive_file, color: textColor),
                      title: Text(
                        doc.fileName ?? 'Document',
                        style: TextStyle(color: textColor),
                      ),
                    );
                  },
                ),
          linkAttachments.isEmpty
              ? _buildEmptyState('No links shared yet', isDarkMode)
              : ListView.builder(
                  itemCount: linkAttachments.length,
                  itemBuilder: (context, index) {
                    final link = linkAttachments[index];
                    return ListTile(
                      leading: Icon(Icons.link, color: textColor),
                      title: Text(link.url, style: TextStyle(color: textColor)),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text, bool isDarkMode) {
    return Center(
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: isDarkMode ? Colors.white54 : Colors.black54,
        ),
      ),
    );
  }
}
