import 'package:flutter/material.dart';

class AppColors {
  // Church brand colors from faithklinikministries.com
  static const Color purple = Color(0xFF4a046a); // Main header purple
  static const Color blue = Color(0xFF094880); // Primary blue
  static const Color darkNavy = Color(0xFF052f55); // Footer navy
  static const Color accentBlue = Color(0xFF1d7aa2); // Teal-blue accent

  // Legacy color names for compatibility
  static const Color brown = Color(0xFF4a046a); // Maps to purple
  static const Color gold = Color(0xFF094880); // Maps to blue

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Children's colors
  static const Color childGreen = Color(0xFF4CAF50);
  static const Color childBlue = Color(0xFF2196F3);
  static const Color childPurple = Color(0xFF9C27B0);
  static const Color childOrange = Color(0xFFFF9800);
  static const Color childYellow = Color(0xFFFFC107);
  static const Color childPink = Color(0xFFE91E63);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [purple, blue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient childGradient = LinearGradient(
    colors: [childGreen, childBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
