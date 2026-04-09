import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF335836);
  static const primaryLight = Color(0xFF7CA971);
  static const accent = Color(0xFFABCBA2);
  
  // Antigravity Backgrounds
  static const background = Color(0xFFFDFCF8);
  static const backgroundDark = Color(0xFF0A0F0C);
  
  // Status Colors
  static const available = Color(0xFFABCBA2);
  static const crowded = Color(0xFFE8C86A);
  static const full = Color(0xFFD36868);

  // Text Colors
  static const textPrimary = Color(0xFF1E2820);
  static const textSecondary = Color(0xFF5A665D);
  
  // Ethereal Elements
  static const glassBase = Color(0x1AFFFFFF);
  static const glassBorder = Color(0x33FFFFFF);
  static const glassShadow = Color(0x1A000000);

  static const primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

