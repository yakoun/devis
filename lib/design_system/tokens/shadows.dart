import 'package:flutter/material.dart';
import 'colors.dart';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x04000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> glass = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x04000000),
      blurRadius: 64,
      offset: Offset(0, 16),
    ),
  ];
}
