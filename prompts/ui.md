
UI Rules

- for colors don't use fixed colors, it runes theme, and difficult to change the colors at all places. instead use theme colors (i don't want material type of colors)
- use the main.dart 

use /lib/main.dart for theming update, use `theme` and `darkTheme` for theme update, even border colors, gray shades use the theme colors, instead of every widget checking isDark and take some fixed colors which causes so much to difficult to later change colors.
- if u want as need create extensions option in theme for providing custom theme properties and colors.

- for gradient button use lib/ui/gradient_btn.dart
- create global constant for gradient to use them other places other 


some htlm, css code used for web, i need these colors::

Base Color: bg-[#FBFCFF]
Background Blobs (Animated with blur-[120px]):
Rose: bg-rose-500/10
Indigo: bg-indigo-500/10
Blue: bg-blue-500/10
Purple: bg-purple-500/10

<button class="bg-linear-to-r from-[#0066FF] to-[#E056FD] text-white px-6 py-2 rounded-xl shadow-lg shadow-blue-200 transition-all hover:scale-105 active:scale-95">
  Click Me
</button>