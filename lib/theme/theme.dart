import 'package:eduprova/theme/theme_model.dart';
import 'package:flutter/material.dart';

export 'theme_model.dart';

extension AppThemeX on BuildContext {
  AppDesignExtension get design =>
      Theme.of(this).extension<AppDesignExtension>()!;
}
