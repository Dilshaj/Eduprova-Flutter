class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String search = '/search';

  // Courses
  static const String courses = '/courses';
  static String courseDetail(String id) => '/course/$id';
  static String courseLearning(String id) => '/course/$id/learn';
  static const String myWishlist = '/my-wishlist';
  static const String myCart = '/my-cart';
  static const String myLearning = '/my-learning';
  static const String billingAndPayments = '/billing-payments';
  static const String profileSettings = '/profile-settings';
  static const String helpAndSupport = '/help-support';

  // Messages & Communities
  static const String messages = '/messages';
  static String chat(String id) => '/chat/$id';
  static String contactDetail(String id) => '/contact/$id';
  static const String createCommunity = '/create-community';
  static const String createChannel = '/create-channel';

  // Status or Stories
  static const String createStory = '/create-story';
  static String statusPager(String id) => '/status/$id';

  // AI Interview
  static const String aiInterview = '/ai/interview';
  static const String aiInterviewSetup = '/ai/interview/setup';
  static const String aiResumeInterview = '/ai/interview/setup-resume';
  static const String interviewHistory = '/ai/interview/history';
  static const String interviewAnalytics = '/ai/interview/analytics';
  static const String interviewLiveAgent = '/ai/interview/live-agent';
  static String interviewFeedback(String id) => '/ai/interview/feedback/$id';

  // Multi-Resume Builder
  static const String resumeBuilderHome = '/resume-builder';
  static const String resumeBuilderList = '/resume-builder/list';
  static String resumeBuilderEditor(String id) => '/resume-builder/$id';
  static const String resumeBuilderImport = '/resume-builder/import';

  // Jobs
  static const String jobs = '/jobs';
  static String jobDetail(String id) => '/job/$id';
  static const String searchJobs = '/jobs/search';
  static const String savedJobs = '/jobs/saved';
  static const String myApplications = '/jobs/applications';
}
