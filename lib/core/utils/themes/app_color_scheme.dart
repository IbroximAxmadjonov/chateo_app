import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppColorScheme {
  /// Светлая тема
  static const Color _primaryLight = BrandColor.defaultMode;
  static const Color _primaryContainerLight = BrandColor.darkMode;
  static const Color _secondaryLight = NeutralColor.active;
  static const Color _secondaryContainerLight = NeutralColor.disable;
  static const Color _surfaceLight = NeutralColor.white;
  static const Color _surfaceContainerLight = NeutralColor.offWhite;
  static const Color _dividerLight = NeutralColor.line;
  static const Color _onPrimaryLight = NeutralColor.offWhite;
  static const Color _onSecondaryLight = Colors.orange; // проверка
  static const Color _onSurfaceDateTimeLight = NeutralColor.weak;
  static const Color _onErrorLight = Colors.white;

  /// Темная тема
  static const Color _primaryDark = BrandColor.darkMode;
  static const Color _primaryContainerDark = BrandColor.light;
  static const Color _secondaryDark = NeutralColor.offWhite;
  static const Color _secondaryContainerDark = NeutralColor.disable;
  static const Color _surfaceDark = NeutralColor.active;
  static const Color _surfaceContainerDark = NeutralColor.dark;
  static const Color _dividerDark = NeutralColor.dark;
  static const Color _onPrimaryDark = NeutralColor.offWhite;
  static const Color _onSecondaryDark = Colors.orange; // проверка
  static const Color _onSurfaceDateTimeDark = NeutralColor.line;
  static const Color _onErrorDark = Colors.black;

  /// Дополнительные цвета
  static const Color _error = AccentColor.danger;
  static const Color _success = AccentColor.success;
  static const Color _warning = AccentColor.warning;
  static const Color _safe = AccentColor.safe;
  static const LinearGradient _gradient1 = GradientColor.variant1;
  static const LinearGradient _gradient2 = GradientColor.variant2;

  /// ==================== СВЕТЛАЯ ТЕМА ====================
  static final ColorScheme lightColorScheme = const ColorScheme.light(
    primary: _primaryLight,
    primaryContainer: _primaryContainerLight,
    secondary: _secondaryLight,
    secondaryContainer: _secondaryContainerLight,
    surface: _surfaceLight,
    surfaceContainer: _surfaceContainerLight,
    error: _error,
    onPrimary: _onPrimaryLight,
    onSecondary: _onSecondaryLight,
    onSurface: _onSurfaceDateTimeLight,
    onSurfaceVariant: _dividerLight,
    onError: _onErrorLight,
  );

  /// ==================== ТЕМНАЯ ТЕМА ====================
  static final ColorScheme darkColorScheme = const ColorScheme.dark(
    primary: _primaryDark,
    primaryContainer: _primaryContainerDark,
    secondary: _secondaryDark,
    secondaryContainer: _secondaryContainerDark,
    surface: _surfaceDark,
    surfaceContainer: _surfaceContainerDark,
    error: _error,
    onPrimary: _onPrimaryDark,
    onSecondary: _onSecondaryDark,
    onSurface: _onSurfaceDateTimeDark,
    onSurfaceVariant: _dividerDark,
    onError: _onErrorDark,
  );
}
