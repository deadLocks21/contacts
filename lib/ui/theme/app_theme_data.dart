import 'package:contacts/core/domain/model/app_theme_mode.dart';
import 'package:contacts/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Assemble les thèmes Material 3 clair/sombre (pattern kidflix/motorz :
/// `abstract final class` + ColorScheme + ThemeExtension `AppColors` + styles
/// de composants centralisés).
///
/// Typographie : la police du système — Roboto sur Android, celle que Google
/// Contacts utilise. Aucune police distante : l'app doit s'ouvrir hors ligne.
abstract final class AppThemeData {
  static ThemeData buildLightTheme() =>
      _build(contactsLightScheme, AppColors.light, Brightness.light);

  static ThemeData buildDarkTheme() => _build(contactsDarkScheme, AppColors.dark, Brightness.dark);

  static ThemeMode toFlutterThemeMode(AppThemeMode mode) => switch (mode) {
    AppThemeMode.clair => ThemeMode.light,
    AppThemeMode.sombre => ThemeMode.dark,
    AppThemeMode.systeme => ThemeMode.system,
  };

  static ThemeData _build(ColorScheme scheme, AppColors colors, Brightness brightness) {
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: brightness);

    return base.copyWith(
      scaffoldBackgroundColor: colors.background,
      extensions: <ThemeExtension<dynamic>>[colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
      ),
      // Le bouton flottant de Contacts est un conteneur bleu clair à texte
      // bleu foncé, et non le `primary` plein de Material.
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.fabBackground,
        foregroundColor: colors.onFab,
        elevation: 3,
        highlightElevation: 3,
        extendedTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surfaceAlt,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.accentSoft,
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
            color: colors.textPrimary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected) ? colors.onAccentSoft : colors.textMuted,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.textMuted,
        titleTextStyle: TextStyle(fontSize: 16, color: colors.textPrimary),
        subtitleTextStyle: TextStyle(fontSize: 14, color: colors.textMuted),
      ),
      dividerTheme: DividerThemeData(color: colors.outline, space: 1, thickness: 1),
      // Champs sans bordure, posés sur un fond gris : c'est la mise en forme
      // des formulaires Google (barre de recherche comprise).
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceField,
        hintStyle: TextStyle(color: colors.textMuted, fontSize: 16),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.accent, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.onAccent,
          minimumSize: const Size(0, 44),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.accent,
          minimumSize: const Size(0, 44),
          side: BorderSide(color: colors.outline),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.accent,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          shape: const StadiumBorder(),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceField,
        side: BorderSide.none,
        labelStyle: TextStyle(color: colors.textPrimary, fontSize: 14),
        shape: const StadiumBorder(),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceAlt,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceAlt,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.textPrimary,
        contentTextStyle: TextStyle(color: colors.background),
        actionTextColor: colors.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
