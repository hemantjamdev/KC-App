import 'package:flutter/material.dart';

/// Centralized Green Boutique color palette for Kapada Creation.
abstract class AppColors {
  const AppColors._();

  // Primary Greens
  static const Color brandGreen900 = Color(0xFF123D2B);
  static const Color brandGreen800 = Color(0xFF18523A);
  static const Color brandGreen700 = Color(0xFF1F6849);
  static const Color brandGreen600 = Color(0xFF2B7A57);
  static const Color brandGreen500 = Color(0xFF3B8F68);
  static const Color brandGreen100 = Color(0xFFDDEDE5);
  static const Color brandGreen50 = Color(0xFFF2F8F5);
  static const Color brandGreen = brandGreen800;

  // Supporting Colors
  static const Color warmIvory = Color(0xFFFAF7F2);
  static const Color softCream = Color(0xFFF7F1E7);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color charcoal = Color(0xFF1D2420);
  static const Color mutedText = Color(0xFF6F7973);
  static const Color borderSoft = Color(0xFFEAE5DC);

  // Brand Accents & Semantic Status Colors
  static const Color goldAccent = Color(0xFFC5A880);
  static const Color goldBronze = Color(0xFFA67C52);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color mutedGold = Color(0xFFB79A5E);
  static const Color accentGlow = Color(0x263B8F68);

  // Aliases for layout compatibility
  static const Color background = warmIvory;
  static const Color surface = surfaceWhite;
  static const Color surfaceLight = softCream;
  static const Color surfaceBorder = borderSoft;

  static const Color primary = brandGreen800;
  static const Color primaryLight = brandGreen600;
  static const Color primaryDark = brandGreen900;
  static const Color secondary = brandGreen100;

  static const Color textPrimary = charcoal;
  static const Color textSecondary = charcoal;
  static const Color textMuted = mutedText;
  static const Color textHint = mutedText;
  static const Color transparent = Colors.transparent;
}
