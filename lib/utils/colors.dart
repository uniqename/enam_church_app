import 'package:flutter/material.dart';

class AppColors {
  // Church brand colors
  static const Color brown = Color(0xFF8B4513);
  static const Color gold = Color(0xFFD4AF37);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Kids colors
  static const Color kidsGreen = Color(0xFF4CAF50);
  static const Color kidsBlue = Color(0xFF2196F3);
  static const Color kidsPurple = Color(0xFF9C27B0);
  static const Color kidsOrange = Color(0xFFFF9800);
  static const Color kidsYellow = Color(0xFFFFC107);
  static const Color kidsPink = Color(0xFFE91E63);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [brown, gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient kidsGradient = LinearGradient(
    colors: [kidsGreen, kidsBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
