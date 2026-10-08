import 'package:flutter/material.dart';

class AppColors {
  // ─── Kashmir Blue Official Brand Scale ─────────────────────────────────────
  static const Color kashmirBlue50 = Color(0xFFF5F7FA);
  static const Color kashmirBlue100 = Color(0xFFEAEEF4);
  static const Color kashmirBlue200 = Color(0xFFD0DAE7);
  static const Color kashmirBlue300 = Color(0xFFA7BAD2);
  static const Color kashmirBlue400 = Color(0xFF7895B8);
  static const Color kashmirBlue500 = Color(0xFF5778A0);
  static const Color kashmirBlue600 = Color(0xFF4A6993);
  static const Color kashmirBlue700 = Color(0xFF374D6D);
  static const Color kashmirBlue800 = Color(0xFF31425B); // Primary main color
  static const Color kashmirBlue900 = Color(0xFF2C3A4E);
  static const Color kashmirBlue950 = Color(0xFF1E2633);

  // ─── Core Semantic Brand Palette ──────────────────────────────────────────
  static const Color primary = kashmirBlue800; // #31425b (Primary main color)
  static const Color primaryDark = kashmirBlue900; // #2c3a4e
  static const Color primaryLight = kashmirBlue600; // #4a6993
  static const Color primaryBrand700 = kashmirBlue700; // #374d6d
  static const Color primaryContainer = kashmirBlue900;
  static const Color primarySubtle = kashmirBlue100; // #eaeef4
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ─── Backgrounds (Clean, crisp Black & White contrast) ─────────────────────
  static const Color background = kashmirBlue50; // #f5f7fa (Crisp canvas)
  static const Color surface = Color(0xFFFFFFFF); // Pure white cards
  static const Color surfaceVariant = kashmirBlue100; // #eaeef4 soft pill/chip fill

  // ─── Darks (Editorial Black & White feel with deep Kashmir undertone) ─────
  static const Color darkBackground = kashmirBlue950; // #1e2633
  static const Color darkSurface = kashmirBlue900; // #2c3a4e
  static const Color darkCard = Color(0xFF161E2A);

  // ─── Gastronomic & Hospitality Accents ────────────────────────────────────
  static const Color ochre = Color(0xFFD4A359); // Champagne gold (complement to Kashmir Blue)
  static const Color ochreDark = Color(0xFFB8863A);
  static const Color ochreSubtle = Color(0xFFFAF4E8);
  static const Color forest = Color(0xFF1E6B47); // Emerald / Open status
  static const Color forestLight = Color(0xFF10B981); // Bright active green indicator
  static const Color forestSubtle = Color(0xFFEDF7F2);
  static const Color terracotta = Color(0xFFD6453D); // Warm coral / terracotta
  static const Color terracottaSubtle = Color(0xFFFDF1F0);
  static const Color sand = kashmirBlue300;

  // ─── Typography (High-contrast Black & White look) ────────────────────────
  static const Color textPrimary = kashmirBlue950; // #1e2633 deep near-black
  static const Color textSecondary = kashmirBlue500; // #5778a0 balanced slate
  static const Color textTertiary = kashmirBlue400; // #7895b8 subtle caption

  // ─── Functional & Borders ──────────────────────────────────────────────────
  static const Color border = kashmirBlue200; // #d0dae7 crisp architectural border
  static const Color divider = kashmirBlue100; // #eaeef4
  static const Color success = forest;
  static const Color error = terracotta;
  static const Color warning = ochre;

  // ─── Shadows ───────────────────────────────────────────────────────────────
  static BoxShadow softShadow = BoxShadow(
    color: kashmirBlue950.withValues(alpha: 0.06),
    blurRadius: 16,
    offset: const Offset(0, 4),
  );

  static BoxShadow elevatedShadow = BoxShadow(
    color: kashmirBlue950.withValues(alpha: 0.12),
    blurRadius: 24,
    offset: const Offset(0, 8),
  );
}
