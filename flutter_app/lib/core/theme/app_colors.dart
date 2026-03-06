// app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary        = Color(0xFFFF9933); // Saffron
  static const Color primaryDark    = Color(0xFFE8861A);
  static const Color primaryLight   = Color(0xFFFFD199);
  static const Color secondary      = Color(0xFF138808); // India Green
  static const Color secondaryLight = Color(0xFFD4EDD4);
  static const Color accent         = Color(0xFF000088); // Navy Blue

  // ── Coin / Reward ────────────────────────────────────────────────────────
  static const Color coinGold       = Color(0xFFFFD700);
  static const Color coinGoldDark   = Color(0xFFFFA000);
  static const Color rewardPurple   = Color(0xFF7C4DFF);
  static const Color rewardPurpleLight = Color(0xFFEDE7F6);

  // ── Light-mode surfaces ───────────────────────────────────────────────────
  static const Color background     = Color(0xFFF7F7FA);  // Slightly cooler
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2F2F6);
  static const Color divider        = Color(0xFFE8E8EC);

  // ── Dark-mode surfaces ────────────────────────────────────────────────────
  static const Color backgroundDark     = Color(0xFF0A0A0F);
  static const Color surfaceDark        = Color(0xFF16161C);
  static const Color surfaceVariantDark = Color(0xFF222230);
  static const Color dividerDark        = Color(0xFF2A2A36);

  // ── Light-mode text ───────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF111118);
  static const Color textSecondary = Color(0xFF555560);
  static const Color textTertiary  = Color(0xFF8E8E9A);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Dark-mode text ────────────────────────────────────────────────────────
  static const Color textPrimaryDark   = Color(0xFFF2F2F6);
  static const Color textSecondaryDark = Color(0xFFAAAAAF);
  static const Color textTertiaryDark  = Color(0xFF66666E);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF00C853);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error        = Color(0xFFE53935);
  static const Color errorLight   = Color(0xFFFFEBEE);
  static const Color warning      = Color(0xFFFF9100);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info         = Color(0xFF2979FF);
  static const Color infoLight    = Color(0xFFE3F2FD);

  // ── Metric Colors ─────────────────────────────────────────────────────────
  static const Color caloriesOrange  = Color(0xFFFF6D00);
  static const Color distanceBlue   = Color(0xFF2979FF);
  static const Color activeGreen    = Color(0xFF00C853);
  static const Color stepsAmber     = Color(0xFFFF9933);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF9933), Color(0xFFFFB84D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroDark = LinearGradient(
    colors: [Color(0xFF16161C), Color(0xFF222230)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}