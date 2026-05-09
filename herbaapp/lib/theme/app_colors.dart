import 'package:flutter/material.dart';

/// Brand palette. Accent values are mode-agnostic; surface/text values are
/// expected to flow from `Theme.of(context).colorScheme` so they adapt to
/// light/dark mode.
class AppColors {
  AppColors._();

  // Brand accents — used in both modes.
  static const Color forest = Color(0xFF2E5D44);
  static const Color leaf = Color(0xFF4A8B6A);
  static const Color sage = Color(0xFFA8C9A6);
  static const Color mint = Color(0xFFD8EDD3);
  static const Color sun = Color(0xFFE8B257);
  static const Color ember = Color(0xFFC25A3F);
  static const Color sky = Color(0xFF7DB1C9);

  // Light-mode neutrals (kept for backwards compatibility in painters that
  // can't reach a BuildContext).
  static const Color cream = Color(0xFFF6F4EC);
  static const Color bark = Color(0xFF3A3530);
  static const Color soil = Color(0xFF6E5B45);
  static const Color textPrimary = bark;
  static const Color textSecondary = Color(0xFF6B6760);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFEFEDE3);
  static const Color border = Color(0xFFE2DFD3);

  // Dark-mode neutrals.
  static const Color nightBg = Color(0xFF0E1714);
  static const Color nightSurface = Color(0xFF182520);
  static const Color nightSurfaceElevated = Color(0xFF1F2D27);
  static const Color nightBorder = Color(0xFF2C3D34);
  static const Color nightTextPrimary = Color(0xFFE8EDE7);
  static const Color nightTextSecondary = Color(0xFFB5BEB7);

  // Semantic
  static const Color success = leaf;
  static const Color warning = sun;
  static const Color danger = ember;

  // Gradients
  static const Gradient ecoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [forest, leaf],
  );

  static const Gradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sun, ember],
  );

  static const Gradient coolGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [sky, mint],
  );
}

/// Convenience access to theme-driven colors that swap between modes.
extension EcoColorScheme on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // Mint is a brand color in light mode but reads as a dark forest tint
  // in dark mode for chips and selection backgrounds.
  Color get mintTint => isDark
      ? AppColors.leaf.withValues(alpha: 0.18)
      : AppColors.mint;

  // Bark is the contrast text color used on top of warm/cool gradients.
  // Same in both modes since gradients keep light backgrounds.
  Color get onGradient => AppColors.bark;
}
