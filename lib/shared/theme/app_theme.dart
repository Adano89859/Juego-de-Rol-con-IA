import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme configuration.
///
/// Era-adaptive theming is prepared here: future versions can switch
/// color palettes based on the game world's current era.
class AppTheme {
  AppTheme._();

  // ── Era-based color palettes ──
  static const _medievalPrimary = Color(0xFF8B6914);
  static const _medievalSecondary = Color(0xFF4A6741);
  // ignore: unused_field
  static const _medievalSurface = Color(0xFF2D1B00);

  // ── Dark Theme (default) ──
  static ThemeData dark({String era = 'medieval'}) {
    final primary = _primaryForEra(era);
    final secondary = _secondaryForEra(era);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: const Color(0xFF1A1A2E),
        onSurface: const Color(0xFFE0E0E0),
      ),
      textTheme: GoogleFonts.merriweatherTextTheme(
        ThemeData.dark().textTheme,
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF16213E),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F3460),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        titleTextStyle: GoogleFonts.merriweather(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFE0E0E0),
        ),
      ),
    );
  }

  // ── Light Theme ──
  static ThemeData light({String era = 'medieval'}) {
    final primary = _primaryForEra(era);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: _secondaryForEra(era),
        surface: const Color(0xFFF5F0E8),
      ),
      textTheme: GoogleFonts.merriweatherTextTheme(
        ThemeData.light().textTheme,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  static Color _primaryForEra(String era) {
    switch (era) {
      case 'steampunk':
        return const Color(0xFFB8860B);
      case 'futuristic':
        return const Color(0xFF00BCD4);
      case 'postapocalyptic':
        return const Color(0xFF795548);
      default:
        return _medievalPrimary;
    }
  }

  static Color _secondaryForEra(String era) {
    switch (era) {
      case 'steampunk':
        return const Color(0xFF8D6E63);
      case 'futuristic':
        return const Color(0xFF7C4DFF);
      case 'postapocalyptic':
        return const Color(0xFF607D8B);
      default:
        return _medievalSecondary;
    }
  }
}
