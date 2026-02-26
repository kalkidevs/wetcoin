import 'package:flutter/material.dart';

class DesignSystem {
  // Spacing Scale
  static const double s2 = 2.0;
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s48 = 48.0;
  static const double s64 = 64.0;

  // Elevation Scale
  static const List<BoxShadow> elevationLow = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> elevationMedium = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> elevationHigh = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> elevationGlow = [
    BoxShadow(
      color: Color(0x33FFD700), // Gold glow
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 2,
    ),
  ];

  // Motion System
  static const Curve curveEaseOut = Curves.easeOutCubic;
  static const Curve curveEaseIn = Curves.easeInCubic;
  static const Curve curveBounce = Curves.elasticOut;
  static const Curve curveSmooth = Curves.easeInOutQuad;

  // Animation Durations
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 350);
  static const Duration durationSlow = Duration(milliseconds: 600);
  static const Duration durationVerySlow = Duration(milliseconds: 1000);

  // Colors (Emotional Design Palette)
  static const Color primary = Color(0xFF6C63FF); // Main Purple
  static const Color secondary = Color(0xFFFF6584); // Joyful Pink
  static const Color accent = Color(0xFFFFD700); // Gold Coin
  static const Color success = Color(0xFF00C853); // Growth Green
  static const Color background = Color(0xFFF8F9FE); // Clean Background
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF9094A6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4834D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coinGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient progressGradient = LinearGradient(
    colors: [Color(0xFFFF9966), Color(0xFFFF5E62)], // Saffron to Red/Pink
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );
}
