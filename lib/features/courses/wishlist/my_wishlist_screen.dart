import 'package:eduprova/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'wishlist_provider.dart';
import '../core/providers/course_provider.dart';
import '../core/models/course_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyWishlistScreen extends ConsumerWidget {
  const MyWishlistScreen({super.key});

  Widget _buildFooterComponent(
    AppDesignExtension themeExt,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: .start,
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
                  crossAxisAlignment: .start,
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

  Widget _buildWishlistItem(
    BuildContext context,
    CourseModel item,
    WidgetRef ref,
    AppDesignExtension themeExt,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeExt.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 100,
              height: 100,
              color: themeExt.skeletonBase,
              child: item.thumbnail != null
                  ? CachedNetworkImage(
                      imageUrl: item.thumbnail!,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image_not_supported),
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  crossAxisAlignment: .start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        ref
                            .read(wishlistProvider.notifier)
                            .removeFromWishlist(item.id);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.favorite,
                          size: 20,
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.instructor?.fullName ?? 'Unknown Instructor',
                  style: TextStyle(fontSize: 12, color: themeExt.secondaryText),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₹${item.discountedPrice ?? item.originalPrice}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (item.discountedPrice != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '₹${item.originalPrice}',
                        style: TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: themeExt.secondaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    final coursesState = ref.watch(coursesProvider);
    final wishlistState = ref.watch(wishlistProvider);

    final wishlistCourses = coursesState.courses
        .where((course) => wishlistState.ids.contains(course.id))
        .toList();

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
                          '${wishlistCourses.length} SAVED COURSES',
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
                child: (wishlistState.isLoading && wishlistCourses.isEmpty)
                    ? const Center(child: CircularProgressIndicator())
                    : wishlistCourses.isEmpty
                    ? ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        children: [
                          _buildEmptyComponent(context, themeExt, colorScheme),
                          _buildFooterComponent(themeExt, colorScheme),
                        ],
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        itemCount: wishlistCourses.length + 1,
                        itemBuilder: (context, index) {
                          if (index == wishlistCourses.length) {
                            return _buildFooterComponent(themeExt, colorScheme);
                          }
                          return _buildWishlistItem(
                            context,
                            wishlistCourses[index],
                            ref,
                            themeExt,
                            colorScheme,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
