import 'package:eduprova/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

class MyWishlistScreen extends StatelessWidget {
  const MyWishlistScreen({super.key});

  Widget _buildFooterComponent(
    AppDesignExtension themeExt,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recommended Deals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: themeExt.errorBackgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'ENDS SOON',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Promo Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -44,
                  right: -44,
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -34,
                  left: -34,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PREMIUM TRACK OFFER',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Color(0xFFC7D2FE),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Master full-stack development with 90% off for the next 2 hours.',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Explore Now',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4338CA),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyComponent(
    BuildContext context,
    AppDesignExtension themeExt,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 80, bottom: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.favorite_border, size: 64, color: themeExt.borderColor),
          const SizedBox(height: 16),
          Text(
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeExt.secondaryText,
            ),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Browse Courses',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: themeExt.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: themeExt.cardColor,
                  border: Border(
                    bottom: BorderSide(color: themeExt.borderColor),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => context.pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.chevron_left,
                          size: 24,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    // Consumer<CoursesProvider>(
                    //   builder: (context, provider, child) {
                    // return Column(
                    //   children: [
                    //     Text(
                    //       'My Wishlist',
                    //       style: TextStyle(
                    //         fontSize: 18,
                    //         fontWeight: FontWeight.bold,
                    //         color: colorScheme.onSurface,
                    //       ),
                    //     ),
                    //     Text(
                    //       '\${provider.wishlist.length} SAVED COURSES',
                    //       style: TextStyle(
                    //         fontSize: 12,
                    //         fontWeight: FontWeight.bold,
                    //         letterSpacing: 1,
                    //         color: colorScheme.primary,
                    //       ),
                    //     ),
                    //   ],
                    // );
                    // },
                    // ),
                    Column(
                      children: [
                        Text(
                          'My Wishlist',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '0 SAVED COURSES',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.more_vert,
                          size: 20,
                          color: themeExt.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                // Consumer<CoursesProvider>(
                //   builder: (context, provider, child) {
                //     final wishlist = provider.wishlist;
                //     if (wishlist.isEmpty) {
                //       return ListView(
                //         physics: const BouncingScrollPhysics(),
                //         padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                //         children: [
                //           _buildEmptyComponent(context, themeExt, colorScheme),
                //           _buildFooterComponent(themeExt, colorScheme),
                //         ],
                //       );
                //     }
                //
                //     return ListView.builder(
                //       physics: const BouncingScrollPhysics(),
                //       padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                //       itemCount: wishlist.length + 1,
                //       itemBuilder: (context, index) {
                //         if (index == wishlist.length) {
                //           return _buildFooterComponent(themeExt, colorScheme);
                //         }
                //         return _buildWishlistItem(
                //           context,
                //           wishlist[index],
                //           provider,
                //           themeExt,
                //           colorScheme,
                //         );
                //       },
                //     );
                //   },
                // ),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  children: [
                    _buildEmptyComponent(context, themeExt, colorScheme),
                    _buildFooterComponent(themeExt, colorScheme),
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
