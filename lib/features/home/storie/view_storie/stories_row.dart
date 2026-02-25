import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:eduprova/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'stories_provider.dart';

class StatusRow extends ConsumerStatefulWidget {
  const StatusRow({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StatusRowState();
}

class _StatusRowState extends ConsumerState<StatusRow> {
  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(statusProfilesProvider);

    return SizedBox(
      height: 105,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        itemCount: profiles.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddStoryCard(context);
          }
          return _buildStatusCard(context, index - 1, profiles[index - 1]);
        },
      ),
    );
  }

  Widget _buildAddStoryCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).push(AppRoutes.createStory);
      },
      child: Container(
        width: 80,
        decoration: DottedDecoration(
          shape: Shape.box,
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).colorScheme.outline,
          dash: const [6, 4],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 28),
            SizedBox(height: 4),
            Text(
              'Add Story',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    int index,
    StatusProfile profile,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) => StatusUsersPager(initialIndex: index),
        //   ),
        // );
        context.push(AppRoutes.statusPager(index.toString()));
      },
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.purple, Colors.pink, Colors.orange],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(21.5),
          ),
          padding: const EdgeInsets.all(2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19.5),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildStatusThumbnail(profile, index),
                Positioned(
                  left: 6,
                  bottom: 8,
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 1.5,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(profile.profileUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusThumbnail(StatusProfile profile, int index) {
    if (profile.statuses.isEmpty) {
      return Image.network(
        'https://picsum.photos/seed/$index/150/200',
        fit: BoxFit.cover,
      );
    }

    final firstStatus = profile.statuses.first;
    if (firstStatus.type == StatusType.video) {
      // For video status, we could show a video icon or a placeholder
      // For now, let's use a blurred version of the profile picture or a generic gradient
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withValues(alpha: 0.8), Colors.black45],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: const Center(
          child: Icon(Icons.play_circle_outline, color: Colors.white, size: 30),
        ),
      );
    }

    return Image.network(
      firstStatus.url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
    );
  }
}
