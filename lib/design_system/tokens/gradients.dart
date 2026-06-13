import 'package:flutter/material.dart';
import 'colors.dart';

class AppGradients {
  AppGradients._();

  static LinearGradient card(bool isDark) {
    if (isDark) {
      return const LinearGradient(
        colors: [Color(0xFF132042), Color(0xFF0F1A2E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static const LinearGradient darkBackground = LinearGradient(
    colors: [Color(0xFF081120), Color(0xFF0F1A2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFF4895EF), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orange = LinearGradient(
    colors: [Color(0xFFF4A261), Color(0xFFE76F51)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient green = LinearGradient(
    colors: [Color(0xFF06D6A0), Color(0xFF118AB2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassLight = LinearGradient(
    colors: [Color(0xE6FFFFFF), Color(0xCCF8F9FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
