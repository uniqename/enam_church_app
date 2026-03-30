import 'package:flutter/material.dart';

class AppColors {
  // ── Brand (light mode) ─────────────────────────────────────────────────────
  static const Color purple   = Color(0xFF4a046a);
  static const Color blue     = Color(0xFF094880);
  static const Color darkNavy = Color(0xFF052f55);
  static const Color accentBlue = Color(0xFF1d7aa2);
  static const Color primary  = purple;

  // Legacy aliases
  static const Color brown = Color(0xFF4a046a);
  static const Color gold  = Color(0xFF094880);

  // ── Dark mode surfaces ──────────────────────────────────────────────────────
  static const Color darkBg       = Color(0xFF0A0A0F);
  static const Color darkSurface  = Color(0xFF13131A);
  static const Color darkSurface2 = Color(0xFF1C1C26);
  static const Color darkBorder   = Color(0xFF2A2A38);
  static const Color darkDivider  = Color(0xFF222230);

  // ── Accent palette (dark mode pops) ────────────────────────────────────────
  static const Color accentPurple = Color(0xFF9B59FF);
  static const Color accentGold   = Color(0xFFF5C842);
  static const Color accentTeal   = Color(0xFF00D4AA);
  static const Color accentRose   = Color(0xFFFF6B9D);

  // ── Status ─────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color error   = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info    = Color(0xFF2196F3);

  // ── Children ───────────────────────────────────────────────────────────────
  static const Color childGreen  = Color(0xFF4CAF50);
  static const Color childBlue   = Color(0xFF2196F3);
  static const Color childPurple = Color(0xFF9C27B0);
  static const Color childOrange = Color(0xFFFF9800);
  static const Color childYellow = Color(0xFFFFC107);
  static const Color childPink   = Color(0xFFE91E63);

  // ── Platform stream colors ──────────────────────────────────────────────────
  static const Color youtube   = Color(0xFFFF0000);
  static const Color instagram = Color(0xFFE1306C);
  static const Color facebook  = Color(0xFF1877F2);
  static const Color zoom      = Color(0xFF2D8CFF);
  static const Color googleMeet = Color(0xFF00897B);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [purple, blue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A0A2E), darkBg],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentPurple, Color(0xFF6A0DAD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient childGradient = LinearGradient(
    colors: [childGreen, childBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Glow helpers ───────────────────────────────────────────────────────────
  static List<BoxShadow> glowPurple({double radius = 18, double opacity = 0.25}) => [
    BoxShadow(color: accentPurple.withOpacity(opacity), blurRadius: radius, spreadRadius: 0),
  ];
  static List<BoxShadow> glowGold({double radius = 14, double opacity = 0.22}) => [
    BoxShadow(color: accentGold.withOpacity(opacity), blurRadius: radius, spreadRadius: 0),
  ];
  static List<BoxShadow> glowColor(Color c, {double radius = 14, double opacity = 0.28}) => [
    BoxShadow(color: c.withOpacity(opacity), blurRadius: radius, spreadRadius: 0),
  ];
}
