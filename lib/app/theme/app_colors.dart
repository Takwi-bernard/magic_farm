import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  //main brand colors
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF66BB6A);
  static const Color primaryDark = Color(0xFF1B5E20);

  // Agriculture accent — pulled from the actual logo mark, which used
  // a bright lime green and a warm brown that weren't captured here
  // before. Everything was green/gray without these; adding them gives
  // the UI somewhere to go for warmth (captions, highlights, badges)
  // without introducing an unrelated color.
  static const Color accent = Color(0xFF8BC34A);
  static const Color accentWarm = Color(0xFF6D4C41);

  static const Color background = Color(0xFFF8F9F5);
  static const Color surface = Colors.white;

  //text
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);

  //status colors
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF1976D2);

  //borders
  static const Color border = Color(0xFFE5E7EB);
}
