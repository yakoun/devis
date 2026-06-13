import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Accent
  static const Color accent = Color(0xFF4895EF);
  static const Color accentSoft = Color(0xFF00B4D8);
  static const Color accentPurple = Color(0xFF7B61FF);
  static const Color accentGreen = Color(0xFF06D6A0);
  static const Color accentOrange = Color(0xFFF4A261);
  static const Color accentRed = Color(0xFFEF476F);
  static const Color accentYellow = Color(0xFFFFD166);

  // Dark
  static const Color darkBackground = Color(0xFF081120);
  static const Color darkSurface = Color(0xFF0F1A2E);
  static const Color darkSurfaceLight = Color(0xFF1A2744);
  static const Color darkCard = Color(0xFF132042);
  static const Color darkBorder = Color(0xFF1E2D50);

  // Light
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF0F2F5);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnDark = Color(0xFFF8F9FA);
  static const Color textOnDarkSecondary = Color(0xFF9CA3AF);
  static const Color textOnDarkTertiary = Color(0xFF6B7280);

  // Glass
  static const Color glassWhite = Color(0x14FFFFFF);
  static const Color glassWhiteLight = Color(0x0AFFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);

  // Semantic
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFFD166);
  static const Color error = Color(0xFFEF476F);
  static const Color info = Color(0xFF4895EF);

  // Chart
  static const Color chartLine = Color(0xFF4895EF);
  static const Color chartFill = Color(0xFF4895EF);
  static const Color chartGrid = Color(0x14FFFFFF);

  // Deprecated aliases (old API compatibility)
  @Deprecated('Use accent instead') static const Color electricBlue = Color(0xFF4895EF);
  @Deprecated('Use accentSoft instead') static const Color electricCyan = Color(0xFF00B4D8);
  @Deprecated('Use accentPurple instead') static const Color electricPurple = Color(0xFF7B61FF);
  @Deprecated('Use accentGreen instead') static const Color electricGreen = Color(0xFF06D6A0);
  @Deprecated('Use accentRed instead') static const Color electricRed = Color(0xFFEF476F);
  @Deprecated('Use accentOrange instead') static const Color electricOrange = Color(0xFFF4A261);
  @Deprecated('Use accentYellow instead') static const Color electricYellow = Color(0xFFFFD166);
}
