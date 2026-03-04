---
description: Best practices for implementing Flutter UI components and widgets
---

# Flutter UI Best Practices

This workflow guides you on creating optimized, readable, and reusable Flutter UI code.

## 1. Split Code into Multiple Files
Avoid monolithic files. If a screen or feature contains multiple distinct sub-sections, place each logical sub-section into its own file (e.g., `_header.dart`, `_body.dart`, `_footer.dart`) and export or construct them together.

## 2. Create Separate Widgets for Optimization
When a portion of UI has state but doesn't require the parent widget to rebuild, extract it into a separate `StatefulWidget` or `ConsumerWidget` (if using Riverpod). This confines the rebuilds to the smallest possible sub-tree.
* Example: A favorite button that only needs to toggle its own icon should be a separate widget rather than calling `setState` on the entire page.

## 3. Extract Widget Methods
To prevent massive, deeply-nested `build` methods, break down parts of the UI into smaller builder methods within the same class or pass them as properties.
* Example: Instead of nesting `Column > Row > Expanded > Container...` into one giant block, create methods like `Widget _buildHeader(BuildContext context)` or `Widget _buildList(BuildContext context)`.

## 4. Reusable Widgets
Any UI element that is used in more than two places across the application should be abstracted into a common/shared widget. Create configurable parameters (colors, callbacks, text) instead of hardcoding specific values. 

Follow these rules whenever constructing, refactoring, or generating new UI code in Flutter.