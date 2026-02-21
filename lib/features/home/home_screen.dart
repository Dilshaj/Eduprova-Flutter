import 'dart:ui';

import 'package:edupurva/features/home/bottom_nav/bottom_nav1.dart';
import 'package:edupurva/features/home/bottom_nav/bottom_nav2.dart';
import 'package:edupurva/features/home/posts/post.dart';
import 'package:edupurva/features/home/status/status_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showBars = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark
        ? Colors.black.withValues(alpha: 0.8)
        : const Color.fromARGB(255, 230, 230, 230).withValues(alpha: 0.8);
    final double blur = isDark ? 30 : 20;
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,

      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse) {
            if (_showBars) setState(() => _showBars = false);
          } else if (notification.direction == ScrollDirection.forward) {
            if (!_showBars) setState(() => _showBars = true);
          }
          return true;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text("Surya"),
              centerTitle: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              floating: true,
              snap: true,
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: Container(color: color),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: StatusRow(),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Post(
                  post: PostModel(
                    id: index.toString(),
                    name: "Riya Wilson",
                    designation: "Product Designer",
                    timeAgo: "3h ago",
                    content:
                        "I just built a new design system for my side project using AI and it helped me generate 80% of the design elements!\nWhat do you think about it:",
                    imageUrl: "https://picsum.photos/seed/${index}abc/600/300",
                    authorAvatar: "assets/avatars/${index % 12 + 1}.png",
                    createdAt: DateTime.now(),
                  ),
                ),

                // (context, index) => const Padding(
                //   padding: EdgeInsets.all(16),
                //   child: Text("Hello"),
                // ),
                childCount: 100,
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        offset: _showBars ? Offset.zero : const Offset(0, 2),
        curve: Curves.easeIn,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _showBars ? 1 : 0,
          child: Transform.translate(
            offset: const Offset(
              0,
              20,
            ), // Move it down completely into the navbar hole
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A8BFF).withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A8BFF), Color(0xFFFF61D8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.transparent,
                elevation: 0,
                highlightElevation: 0,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _hideNav(const BottomNav2()),
    );
  }

  Widget _hideNav(Widget child) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 250),
      offset: _showBars ? Offset.zero : const Offset(0, 1),
      curve: Curves.easeIn,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _showBars ? 1 : 0,
        child: child,
      ),
    );
  }
}
