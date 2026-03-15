// import 'dart:ui';

// import 'package:eduprova/features/home/posts/post.dart';
// import 'package:eduprova/features/home/storie/view_storie/stories_row.dart';
// import 'package:eduprova/theme.dart';
// import 'package:eduprova/ui/background.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hugeicons/hugeicons.dart';
// import 'package:eduprova/ui/animated_title_header.dart';
// import 'package:eduprova/features/home/main_layout.dart';

// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends ConsumerState<HomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final color = isDark ? Colors.black.withValues(alpha: 0.8) : Colors.white;
//     final double blur = isDark ? 30 : 20;

//     return Scaffold(
//       // extendBody: true,
//       // extendBodyBehindAppBar: true,
//       body: Stack(children: [AppBackground(), _buildBody(blur, color)]),
//       // drawer:
//     );
//   }

//   Widget _buildBody(double blur, Color color) {
//     final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
//     return NotificationListener<UserScrollNotification>(
//       // onNotification: (notification) {
//       //   if (notification.direction == ScrollDirection.reverse) {
//       //     if (_showBars) setState(() => _showBars = false);
//       //   } else if (notification.direction == ScrollDirection.forward) {
//       //     if (!_showBars) setState(() => _showBars = true);
//       //   }
//       //   return true;
//       // },
//       child: CustomScrollView(
//         slivers: [
//           // show profile image, title, icons
//           // SliverAppBar(
//           //   backgroundColor: Colors.transparent,
//           //   leading: IconButton(
//           //     onPressed: () {
//           //       mainScaffoldKey.currentState?.openDrawer();
//           //     },
//           //     icon: HugeIcon(icon: HugeIcons.strokeRoundedMenu02),
//           //   ),
//           //   title: ShaderMask(
//           //     shaderCallback: (bounds) =>
//           //         themeExt.buyNowGradient.createShader(bounds),
//           //     child: const Text(
//           //       "EduProva",
//           //       style: TextStyle(
//           //         fontSize: 24,
//           //         fontWeight: FontWeight.bold,
//           //         color: Colors.white, // required
//           //       ),
//           //     ),
//           //   ),
//           //   actions: [
//           //     IconButton(icon: const Icon(Icons.search), onPressed: () {}),
//           //     IconButton(
//           //       icon: const Icon(Icons.notifications),
//           //       onPressed: () {},
//           //     ),
//           //     const Padding(
//           //       padding: EdgeInsets.symmetric(horizontal: 16.0),
//           //       child: CircleAvatar(
//           //         radius: 16,
//           //         backgroundImage: AssetImage('assets/avatars/1.png'),
//           //       ),
//           //     ),
//           //   ],
//           //   centerTitle: false,
//           //   scrolledUnderElevation: 0,
//           //   elevation: 0,
//           //   surfaceTintColor: Colors.transparent,
//           //   // backgroundColor: themeExt.scaffoldBackgroundColor,
//           //   floating: true,
//           //   forceMaterialTransparency: false,
//           //   snap: true,
//           // ),
//           SliverAppBar(
//             backgroundColor: Colors.transparent,
//             floating: true,
//             snap: true,
//             scrolledUnderElevation: 0,
//             elevation: 0,
//             surfaceTintColor: Colors.transparent,
//             centerTitle: false,

//             flexibleSpace: ClipRect(
//               child: BackdropFilter(
//                 filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//                 child: Container(
//                   color: Theme.of(context).brightness == Brightness.dark
//                       ? Colors.black.withValues(alpha: 0.4)
//                       : Colors.white.withValues(alpha: 0.4),
//                 ),
//               ),
//             ),

//             leading: IconButton(
//               onPressed: () {
//                 mainScaffoldKey.currentState?.openDrawer();
//               },
//               icon: HugeIcon(icon: HugeIcons.strokeRoundedMenu02),
//             ),

//             title: ShaderMask(
//               shaderCallback: (bounds) =>
//                   themeExt.buyNowGradient.createShader(bounds),
//               child: const Text(
//                 "EduProva",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),

//             actions: [
//               IconButton(icon: const Icon(Icons.search), onPressed: () {}),
//               IconButton(
//                 icon: const Icon(Icons.notifications),
//                 onPressed: () {},
//               ),
//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16.0),
//                 child: CircleAvatar(
//                   radius: 16,
//                   backgroundImage: AssetImage('assets/avatars/1.png'),
//                 ),
//               ),
//             ],
//           ),
//           const SliverToBoxAdapter(
//             child: Padding(
//               padding: EdgeInsets.symmetric(vertical: 8.0),
//               child: StatusRow(),
//             ),
//           ),

//           SliverToBoxAdapter(
//             child: AnimatedTitleHeader(
//               titles: ["Trending", "All", "Title 2", "Title 3"],
//               initialTitle: "Trending",
//             ),
//           ),

//           SliverList(
//             delegate: SliverChildBuilderDelegate(
//               (context, index) => Post(
//                 post: PostModel(
//                   id: index.toString(),
//                   name: "Riya Wilson",
//                   designation: "Product Designer",
//                   timeAgo: "3h ago",
//                   content:
//                       "I just built a new design system for my side project using AI and it helped me generate 80% of the design elements!\nWhat do you think about it:",
//                   imageUrl: "https://picsum.photos/seed/${index}abc/600/300",
//                   authorAvatar: "assets/avatars/${index % 12 + 1}.png",
//                   createdAt: DateTime.now(),
//                 ),
//               ),
//               childCount: 100,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:ui';

import 'package:eduprova/features/home/posts/post.dart';
import 'package:eduprova/features/home/storie/view_storie/stories_row.dart';
import 'package:eduprova/theme/theme.dart';
import 'package:eduprova/ui/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:eduprova/ui/animated_title_header.dart';
import 'package:eduprova/features/home/main_layout.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 0;

      if (scrolled != _isScrolled) {
        setState(() {
          _isScrolled = scrolled;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(children: [const AppBackground(), _buildBody(isDark)]),
    );
  }

  Widget _buildBody(bool isDark) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          floating: true,
          snap: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,

          flexibleSpace: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isScrolled ? 1 : 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),

          leading: IconButton(
            onPressed: () {
              mainScaffoldKey.currentState?.openDrawer();
            },
            icon: HugeIcon(icon: HugeIcons.strokeRoundedMenu02),
          ),

          title: ShaderMask(
            shaderCallback: (bounds) =>
                themeExt.buyNowGradient.createShader(bounds),
            child: const Text(
              "EduProva",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          actions: [
            IconButton(
              icon: const Icon(LucideIcons.search, size: 22),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(LucideIcons.bell, size: 22),
              onPressed: () {},
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/avatars/1.png'),
              ),
            ),
          ],
        ),

        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: StatusRow(),
          ),
        ),

        const SliverToBoxAdapter(
          child: AnimatedTitleHeader(
            titles: ["Trending", "All", "Title 2", "Title 3"],
            initialTitle: "Trending",
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
            childCount: 100,
          ),
        ),
      ],
    );
  }
}
