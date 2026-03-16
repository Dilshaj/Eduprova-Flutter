import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheManagers {
  static const carouselCacheKey = 'carouselCacheKey';
  static final CacheManager carouselCacheManager = CacheManager(
    Config(
      carouselCacheKey,
      stalePeriod: const Duration(days: 7), // 1 week for carousel images
      maxNrOfCacheObjects: 20,
    ),
  );

  static const courseThumbnailCacheKey = 'courseThumbnailCacheKey';
  static final CacheManager courseThumbnailCacheManager = CacheManager(
    Config(
      courseThumbnailCacheKey,
      stalePeriod: const Duration(days: 30), // 30 days for course thumbnails
      maxNrOfCacheObjects: 100, // accommodate many courses
    ),
  );

  static const avatarCacheKey = 'avatarCacheKey';
  static final CacheManager avatarCacheManager = CacheManager(
    Config(
      avatarCacheKey,
      stalePeriod: const Duration(days: 30), // 30 days for avatars
      maxNrOfCacheObjects: 100,
    ),
  );

  static const postCacheKey = 'postCacheKey';
  static final CacheManager postCacheManager = CacheManager(
    Config(
      postCacheKey,
      stalePeriod: const Duration(days: 7), // 7 days for posts
      maxNrOfCacheObjects: 200, // accommodate more posts in feed
    ),
  );
}
