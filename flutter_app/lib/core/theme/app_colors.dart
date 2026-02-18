import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF9933); // Saffron
  static const Color secondary = Color(0xFF138808); // India Green
  static const Color accent = Color(0xFF000088); // Navy Blue (Chakra)

  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFFBDBDBD);

  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFB74D);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF9933), Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
