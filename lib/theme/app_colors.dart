import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFFF9F7F2); // Warm off-white/cream
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2EFE9);

  // Primary & Dark
  static const Color primary = Color(0xFF141414); // Deep charcoal
  static const Color primaryContainer = Color(0xFF262626);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Gastronomic Palette (from ifood reference)
  static const Color ochre = Color(0xFFD9822B); // Warm amber / ochre
  static const Color forest = Color(0xFF1C4232); // Deep emerald / forest
  static const Color terracotta = Color(0xFFD65839); // Terracotta salmon
  static const Color sand = Color(0xFFC7AD8E); // Warm woodgrain / sand

  // Text
  static const Color textPrimary = Color(0xFF121212);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFF9E9E9E);

  // Functional & Borders
  static const Color border = Color(0xFFE8E4DD);
  static const Color divider = Color(0xFFEFECE6);
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFED6C02);

  // Shadows
  static BoxShadow softShadow = BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 16,
    offset: const Offset(0, 4),
  );

  static BoxShadow elevatedShadow = BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 24,
    offset: const Offset(0, 8),
  );
}
