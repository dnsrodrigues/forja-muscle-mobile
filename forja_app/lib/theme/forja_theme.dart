// lib/theme/forja_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'accent_theme.dart';
import 'forja_colors.dart';

/// Escala tipográfica FORJA: Bebas Neue (títulos), Space Grotesk (corpo).
TextTheme forjaTextTheme(Color text) => TextTheme(
      displayLarge: GoogleFonts.bebasNeue(fontSize: 56, height: 0.95, color: text),
      displayMedium: GoogleFonts.bebasNeue(fontSize: 38, height: 0.95, color: text),
      titleLarge: GoogleFonts.bebasNeue(fontSize: 24, color: text),
      bodyLarge: GoogleFonts.spaceGrotesk(fontSize: 15, color: text),
      bodyMedium: GoogleFonts.spaceGrotesk(fontSize: 13, color: ForjaColors.textDim),
      labelLarge: GoogleFonts.spaceGrotesk(
          fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: text),
    );

/// Tema dark FORJA, parametrizado pelo acento escolhido.
ThemeData forjaTheme(AccentTheme a) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ForjaColors.bg0,
    colorScheme: ColorScheme.fromSeed(
      seedColor: a.accent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: a.accent,
      onPrimary: a.fg,
      surface: ForjaColors.bg1,
      error: ForjaColors.danger,
    ),
    textTheme: forjaTextTheme(ForjaColors.text),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: a.accent,
        foregroundColor: a.fg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    ),
  );
}
