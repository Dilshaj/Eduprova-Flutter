class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String search = '/search';

  // Courses
  static const String courses = '/courses';
  static String courseDetail(String id) => '/course/$id';

  // Messages & Communities
  static const String messages = '/messages';
  static String chat(String id) => '/chat/$id';
  static String contactDetail(String id) => '/contact/$id';
  static const String createCommunity = '/create-community';
  static const String createChannel = '/create-channel';

  // Status or Stories
  static const String createStory = '/create-story';
  static String statusPager(String id) => '/status/$id';
}
