---
trigger: always_on
---



## Colors and Theming

- For Colors don't use fixed colors, it runies our app completely
- Our App Must support both and dark theme
- instead of checking isDark and provided different colors for each manually for each widget, is difficult to refactor  and reuse the same color
- instead use colors from theme.dart, if required new colors use add property to AppDesignExtension class or create new Extension for seperate related properties.
- theme is at @/lib/theme.dart

u can use the theme colors by simply: 
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final themeExt = theme.extension<AppDesignExtension>()!;


## Routing

For routing use GoRouter
@/lib/core/navigation/app_routes.dart, @/lib/routes.dart


## Loaders

- for images use CachedNetworkImage with Shimmer (not Skeletonizer)
- for loading items/widgets/posts this kind, use Skeletonizer instead of CircularProgressIndicator, Shimmer
- for buttons use thripple dots animation + disable button
