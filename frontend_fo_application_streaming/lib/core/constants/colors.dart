import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const primary = Color(0xFFE50914); // Rouge Netflix
  static const background = Color(0xFF141414); // Noir de fond

  // Couleurs de texte
  static const textPrimary = Colors.white;
  static const textSecondary = Colors.white70;
  static const textGray = Color(0xFFB3B3B3);

  // Couleurs d'accent
  static const accent = Colors.grey;

  // Couleurs d'état
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFF44336);
  static const warning = Color(0xFFFF9800);

  // Couleurs de surface
  static const surface = Color(0xFF1E1E1E);
  static const surfaceLight = Color(0xFF2A2A2A);

  // Transparences
  static Color get primaryWithOpacity => primary.withOpacity(0.8);
  static Color get backgroundWithOpacity => background.withOpacity(0.9);
}
