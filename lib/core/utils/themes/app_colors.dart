import 'package:flutter/material.dart';

/// The colors are taken from the Figma pet project.
class BrandColor {
  static const Color darkOnPressed = Color(0xFF001A83);
  static const Color defaultMode = Color(0xFF002DE3);
  static const Color darkMode = Color(0xFF375FFF);
  static const Color light = Color(0xFF879FFF);
  static const Color background = Color(0xFFD2D5F9);
}

class NeutralColor {
  static const Color active = Color(0xFF0F1828);
  static const Color dark = Color(0xFF152033);
  static const Color body = Color(0xFF1B2B48);
  static const Color weak = Color(0xFFA4A4A4);
  static const Color disable = Color(0xFFADB5BD);
  static const Color line = Color(0xFFEDEDED);
  static const Color offWhite = Color(0xFFF7F7FC);
  static const Color white = Color(0xFFFFFFFF);
}

class AccentColor {
  static const Color danger = Color(0xFFE94242);
  static const Color warning = Color(0xFFFDCF41);
  static const Color success = Color(0xFF2CC069);
  static const Color safe = Color(0xFF7BCBCF);
}

class GradientColor {
  static const LinearGradient variant1 = LinearGradient(
    colors: [Color(0xFFD2D5F9), Color(0xFF2C37E1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient variant2 = LinearGradient(
    colors: [Color(0xFFEC9EFF), Color(0xFF5F2EEA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
