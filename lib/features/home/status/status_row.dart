import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatusRow extends ConsumerStatefulWidget {
  const StatusRow({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StatusRowState();
}

class _StatusRowState extends ConsumerState<StatusRow> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddStoryCard(context);
          }
          return _buildStatusCard(context, index);
        },
      ),
    );
  }

  Widget _buildAddStoryCard(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildStatusCard(BuildContext context, int index) {
    return Container(
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
              Image.network(
                'https://picsum.photos/seed/$index/150/200',
                fit: BoxFit.cover,
              ),
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
                          image: NetworkImage(
                            'https://picsum.photos/seed/user$index/50/50',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Maria',
                      style: TextStyle(
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
    );
  }
}
