import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Eco palette — earthy, natural, calm.
  static const Color forest = Color(0xFF2E5D44);
  static const Color leaf = Color(0xFF4A8B6A);
  static const Color sage = Color(0xFFA8C9A6);
  static const Color mint = Color(0xFFD8EDD3);
  static const Color cream = Color(0xFFF6F4EC);
  static const Color bark = Color(0xFF3A3530);
  static const Color soil = Color(0xFF6E5B45);
  static const Color sun = Color(0xFFE8B257);
  static const Color ember = Color(0xFFC25A3F);
  static const Color sky = Color(0xFF7DB1C9);

  // Semantic
  static const Color success = leaf;
  static const Color warning = sun;
  static const Color danger = ember;

  // Surfaces
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFEFEDE3);
  static const Color textPrimary = bark;
  static const Color textSecondary = Color(0xFF6B6760);
  static const Color border = Color(0xFFE2DFD3);

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
