import 'package:flutter/material.dart';

// import '../themes/app_typography.dart';

extension ThemeExtension on BuildContext {
  ThemeData get appTheme => Theme.of(this);

  TextTheme get appTextStyle => appTheme.textTheme;

  // Type get appTypography => AppTypography;

  ColorScheme get appColors => appTheme.colorScheme;
}
