import 'package:flutter/material.dart';

/// Thème de l'application — palette inspirée des apps d'apprentissage
/// ludiques (vert d'action, accents chauds), pensée pour les débutants.
class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF58A700); // vert "valider"
  static const Color primaryDark = Color(0xFF4A8C00);
  static const Color accent = Color(0xFFFFC800); // jaune XP / récompense
  static const Color heart = Color(0xFFFF4B4B); // rouge cœurs
  static const Color locked = Color(0xFFB0B0B0);
  static const Color surface = Color(0xFFF7F7F7);

  /// Famille de police arabe recommandée (à ajouter via google_fonts ou
  /// en bundlant Amiri/Noto Naskh). `null` = police arabe du système.
  static const String? arabicFontFamily = null;

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
      ),
      scaffoldBackgroundColor: Colors.white,
    );

    return base.copyWith(
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  /// Style pour afficher du texte arabe (grand et lisible pour débutants).
  static TextStyle arabic({double size = 34, Color? color}) => TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: size,
        height: 1.6,
        color: color,
        fontWeight: FontWeight.w600,
      );
}
