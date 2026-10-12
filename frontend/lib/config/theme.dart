import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AgriCastTheme {
  // ── Primary Green Palette ─────────────────────────────────
  static const Color primaryDark = Color(0xFF14532D);    // deep forest
  static const Color primary = Color(0xFF166534);         // main green
  static const Color primaryMed = Color(0xFF15803D);      // medium green
  static const Color primaryBright = Color(0xFF16A34A);   // bright green
  static const Color accent = Color(0xFF22C55E);          // vivid accent

  // ── Surface / Background ──────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF0FDF4);         // faint green tint
  static const Color surfaceGreen = Color(0xFFF0FDF4);    // light green badge bg
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF052E16);     // dark sidebar bg
  static const Color divider = Color(0xFFDCFCE7);

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnGreen = Color(0xFFFFFFFF);
  static const Color textGreen = Color(0xFF166534);

  // ── Semantic ──────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF0284C7);

  // ── Border ────────────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderGreen = Color(0xFFBBF7D0);

  // ── Chart Colors ──────────────────────────────────────────
  static const List<Color> chartColors = [
    Color(0xFF16A34A),
    Color(0xFF22C55E),
    Color(0xFF4ADE80),
    Color(0xFF86EFAC),
    Color(0xFFD97706),
    Color(0xFFF59E0B),
    Color(0xFF0284C7),
    Color(0xFF38BDF8),
  ];

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: primary,
        secondary: accent,
        surface: surface,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: surface,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
            fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary),
        displayMedium: GoogleFonts.inter(
            fontSize: 26, fontWeight: FontWeight.w700, color: textPrimary),
        displaySmall: GoogleFonts.inter(
            fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary),
        headlineLarge: GoogleFonts.inter(
            fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        headlineMedium: GoogleFonts.inter(
            fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        headlineSmall: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
        titleMedium: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
        bodyLarge: GoogleFonts.inter(fontSize: 15, color: textPrimary),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: textSecondary),
        bodySmall: GoogleFonts.inter(fontSize: 12, color: textMuted),
        labelLarge: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary),
        labelMedium: GoogleFonts.inter(fontSize: 12, color: textSecondary),
        labelSmall: GoogleFonts.inter(fontSize: 11, color: textMuted),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border, width: 1),
        ),
        color: surfaceCard,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primaryMed),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
        hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 14),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        foregroundColor: textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.12),
        inactiveTrackColor: borderGreen,
        valueIndicatorColor: primary,
        valueIndicatorTextStyle: GoogleFonts.inter(color: white, fontSize: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primaryBright.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.inter(fontSize: 13),
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}
