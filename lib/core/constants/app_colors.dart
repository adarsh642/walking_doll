import 'package:flutter/material.dart';

/// Design tokens for Walking Doll: cute, playful, premium pastel palette.
class AppColors {
  AppColors._();

  // Primary Pastel Tones
  static const Color primaryPink = Color(0xFFFF6584);
  static const Color primaryPurple = Color(0xFF845EC2);
  static const Color softLavender = Color(0xFFD65DB1);
  static const Color pastelPeach = Color(0xFFFF9671);
  static const Color pastelYellow = Color(0xFFFFC75F);
  static const Color mintGreen = Color(0xFF4EBAAA);
  static const Color skyBlue = Color(0xFF48CAE4);

  // Light Theme Surfaces
  static const Color lightBg = Color(0xFFFFF9FA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardSubtle = Color(0xFFFFF1F4);
  static const Color lightTextPrimary = Color(0xFF2C223B);
  static const Color lightTextSecondary = Color(0xFF756A85);
  static const Color lightBorder = Color(0xFFFFE0E8);

  // Dark Theme Surfaces
  static const Color darkBg = Color(0xFF14121E);
  static const Color darkCard = Color(0xFF201C31);
  static const Color darkCardSubtle = Color(0xFF2B2542);
  static const Color darkTextPrimary = Color(0xFFF7F5FA);
  static const Color darkTextSecondary = Color(0xFFAFA9BC);
  static const Color darkBorder = Color(0xFF393254);

  // Type Badges
  static const Color twoDBadge = Color(0xFFFF6584);
  static const Color threeDBadge = Color(0xFF48CAE4);

  // Gradients
  static const LinearGradient cuteHeroGradient = LinearGradient(
    colors: [Color(0xFFFF9671), Color(0xFFFF6584), Color(0xFFD65DB1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0xFFFFF2F6), Color(0xFFF3EFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkCardGlowGradient = LinearGradient(
    colors: [Color(0xFF26203B), Color(0xFF1E1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

