// app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary        = Color(0xFFFF9933); // Saffron
  static const Color primaryDark    = Color(0xFFE8861A); // Pressed / darker saffron
  static const Color primaryLight   = Color(0xFFFFD199); // Tinted saffron
  static const Color secondary      = Color(0xFF138808); // India Green
  static const Color secondaryLight = Color(0xFFD4EDD4);
  static const Color accent         = Color(0xFF000088); // Navy Blue (Chakra)

  // ── Light-mode surfaces ───────────────────────────────────────────────────
  static const Color background     = Color(0xFFF5F5F5);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F0); // cards, chips
  static const Color divider        = Color(0xFFE0E0E0);

  // ── Dark-mode surfaces ────────────────────────────────────────────────────
  static const Color backgroundDark     = Color(0xFF0E0E0E);
  static const Color surfaceDark        = Color(0xFF1C1C1C);
  static const Color surfaceVariantDark = Color(0xFF2A2A2A); // elevated cards
  static const Color dividerDark        = Color(0xFF2E2E2E);

  // ── Light-mode text ───────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF111111); // high contrast
  static const Color textSecondary = Color(0xFF555555); // 4.5 : 1 on white
  static const Color textTertiary  = Color(0xFF888888);
  static const Color textOnPrimary = Color(0xFFFFFFFF); // on saffron button

  // ── Dark-mode text ────────────────────────────────────────────────────────
  static const Color textPrimaryDark   = Color(0xFFF2F2F2);
  static const Color textSecondaryDark = Color(0xFFAAAAAA);
  static const Color textTertiaryDark  = Color(0xFF666666);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error   = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFE65100);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info    = Color(0xFF1565C0);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF9933), Color(0xFFFFB84D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroDark = LinearGradient(
    colors: [Color(0xFF1C1C1C), Color(0xFF2A2A2A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}