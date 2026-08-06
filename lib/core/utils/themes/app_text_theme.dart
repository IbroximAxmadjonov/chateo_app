import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextTheme {
  static TextTheme buildTextTheme(Color textColor) {
    return TextTheme(
      /// Heading 01 [displayMedium]
      displayMedium: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w700),

      /// Heading 02 [displaySmall]
      displaySmall: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700),

      /// Subheading 01 [headlineMedium]
      headlineMedium: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),

      /// Subheading 02 [headlineSmall]
      headlineSmall: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),

      /// Body 01 [titleMedium]
      titleMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),

      /// Body 02 [titleSmall]
      titleSmall: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),

      /// Metadata 01 [bodyLarge]
      bodyLarge: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),

      /// Metadata 02 [bodyMedium]
      bodyMedium: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w400),

      /// Metadata 03 [bodySmall]
      bodySmall: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600),
    ).apply(bodyColor: textColor, displayColor: textColor);
  }
}
