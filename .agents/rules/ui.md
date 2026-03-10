---
trigger: always_on
---

## Colors and Theming

- For Colors don't use fixed colors, it runies our app completely
- Our App Must support both and dark theme
- instead of checking isDark and provided different colors for each manually for each widget, is difficult to refactor  and reuse the same color
- instead use colors from theme.dart, if required new colors use add property to AppDesignExtension class or create new Extension for seperate related properties.
- theme is at @/lib/theme folder checkout light and dark themes from there.

u can use the theme colors by simply: 
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final themeExt = theme.extension<AppDesignExtension>()!;


## Routing

For routing use GoRouter
create folder like this at here:
@/lib/core/navigation/app_routes.dart, @/lib/routes.dart
like this:
```dart
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
```
so we use like this:
```dart
routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, _) => const SignupScreen(),
      ),

```

## Loaders

- for images use CachedNetworkImage with Shimmer (not Skeletonizer)
- for loading items/widgets/posts this kind, use Skeletonizer instead of CircularProgressIndicator, Shimmer
- for buttons use thripple dots animation + disable button, by using this package:  flutter_spinkit: ^5.2.2