import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_color_scheme.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';

class AppTheme {
  static ThemeData get lightTheme =>
      _buildTheme(AppColorScheme.lightColorScheme);

  static ThemeData get darkTheme => _buildTheme(AppColorScheme.darkColorScheme);

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    // попробую использовать AppTypography вместо TextTheme
    final textTheme = AppTextTheme.buildTextTheme(colorScheme.secondary);
    // final appTypography = AppTypography(textColor: colorScheme.secondary);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      /// Текстовая тема
      textTheme: textTheme,

      /// Стили для AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.secondary,
        titleTextStyle: textTheme.headlineMedium,
        // titleTextStyle: appTypography.heading01,
      ),

      scaffoldBackgroundColor: colorScheme.surface,

      /// ==================== СТИЛИ КНОПОК ====================
      /// я не могу забыть проверить это потом
      /// padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

      /// ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: Size(327.w, 52.h),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
              textStyle: textTheme.headlineSmall,
              elevation: 2,
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.pressed)) {
                  return BrandColor.darkOnPressed.withValues(alpha: 0.12);
                }
                if (states.contains(WidgetState.hovered)) {
                  return BrandColor.darkOnPressed.withValues(alpha: 0.08);
                }
                return null;
              }),
            ),
      ),

      /// TextButton
      textButtonTheme: TextButtonThemeData(
        style:
            TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              minimumSize: Size(116.w, 52.h),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              textStyle: textTheme.headlineSmall,
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.pressed)) {
                  return BrandColor.darkOnPressed.withValues(alpha: 0.12);
                }
                if (states.contains(WidgetState.hovered)) {
                  return BrandColor.darkOnPressed.withValues(alpha: 0.08);
                }
                return null;
              }),
            ),
      ),

      /// IconButton
      iconButtonTheme: IconButtonThemeData(
        style:
            IconButton.styleFrom(
              foregroundColor: colorScheme.secondary,
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.pressed)) {
                  return colorScheme.secondary.withValues(alpha: 0.12);
                }
                return null;
              }),
            ),
      ),

      /// SearchBar
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceContainer),
        elevation: const WidgetStatePropertyAll(0), // Убираем стандартную тень, если нужна плоская рамка
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        ),
        hintStyle: WidgetStatePropertyAll(
          textTheme.titleMedium?.copyWith(
            color: colorScheme.secondaryContainer,
          ),
        ),
        textStyle: WidgetStatePropertyAll(textTheme.titleMedium),
        shape: WidgetStateProperty.resolveWith<OutlinedBorder?>((states) {
          const radius = BorderRadius.all(Radius.circular(8));

          if (states.contains(WidgetState.focused)) {
            return RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(color: colorScheme.surfaceContainer, width: 2),
            );
          }
          if (states.contains(WidgetState.error)) {
            return RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(color: colorScheme.error, width: 1),
            );
          }
          // Enabled / default state
          return RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(
              color: colorScheme.surfaceContainer.withValues(alpha: 0.5),
            ),
          );
        }),
      ),

      /// InputDecoration (TextField)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.surfaceContainer),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: colorScheme.surfaceContainer.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.surfaceContainer, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        labelStyle: textTheme.titleMedium,
        hintStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.secondaryContainer,
        ),
        errorStyle: textTheme.titleSmall?.copyWith(color: colorScheme.error),
      ),


      /// Divider
      dividerTheme: DividerThemeData(
        space: 16.h,
        thickness: 1,
        color: colorScheme.onSurfaceVariant,
      ),

      /// BottomNavigationBar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.secondary,
        unselectedItemColor: colorScheme.secondary,
        selectedLabelStyle: textTheme.titleMedium,
        unselectedLabelStyle: textTheme.titleMedium,
        type: BottomNavigationBarType.shifting,
        elevation: 0.0,
      ),
    );
  }
}
