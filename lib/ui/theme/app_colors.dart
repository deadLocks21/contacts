// Tokens de couleur repris de Google Contacts (Material 3, palette Google
// Blue). Pattern kidflix/motorz : palette brute + ThemeExtension `AppColors`
// + `context.appColors`.

import 'package:flutter/material.dart';

/// Palette brute (tokens bas niveau). Ne pas utiliser directement dans l'UI :
/// toujours passer par [AppColors] / `context.appColors`.
abstract final class ContactsPalette {
  // Bleu Google (Material 3)
  static const blue = Color(0xFF0B57D0); // primary (clair)
  static const blueLight = Color(0xFFA8C7FA); // primary (sombre)
  static const blueContainer = Color(0xFFC2E7FF); // conteneur du bouton flottant (clair)
  static const onBlueContainer = Color(0xFF001D35);
  static const blueContainerDark = Color(0xFF004A77); // conteneur du bouton flottant (sombre)
  static const onBlueContainerDark = Color(0xFFC2E7FF);
  static const blueSoft = Color(0xFFD3E3FD); // sélection, pastilles actives (clair)
  static const blueSoftDark = Color(0xFF0842A0);

  // Neutres — clair
  static const white = Color(0xFFFFFFFF);
  static const grey50 = Color(0xFFF8F9FA); // fond des écrans secondaires
  static const grey100 = Color(0xFFF1F3F4); // barre de recherche, champs
  static const grey200 = Color(0xFFE8EAED);
  static const outlineLight = Color(0xFFE1E3E1);
  static const ink = Color(0xFF1F1F1F); // texte principal
  static const inkMuted = Color(0xFF444746); // texte secondaire

  // Neutres — sombre
  static const grey900 = Color(0xFF131314); // fond
  static const grey850 = Color(0xFF1E1F20); // surface
  static const grey800 = Color(0xFF2D2F31); // barre de recherche, champs
  static const grey750 = Color(0xFF37393B);
  static const outlineDark = Color(0xFF444746);
  static const inkInverse = Color(0xFFE3E3E3);
  static const inkMutedInverse = Color(0xFFC4C7C5);

  static const red = Color(0xFFB3261E); // erreurs, suppression (clair)
  static const redLight = Color(0xFFF2B8B5); // erreurs, suppression (sombre)
  static const star = Color(0xFFF9AB00); // étoile des favoris

  /// Couleurs des pastilles d'initiales, dans l'ordre de l'index rendu par
  /// `AvatarColor.indexFor`. Douze teintes saturées à texte blanc, comme les
  /// avatars sans photo de Google Contacts.
  static const avatars = <Color>[
    Color(0xFFDB4437), // rouge
    Color(0xFFE91E63), // rose
    Color(0xFF9C27B0), // violet
    Color(0xFF673AB7), // violet foncé
    Color(0xFF3F51B5), // indigo
    Color(0xFF4285F4), // bleu
    Color(0xFF0097A7), // cyan
    Color(0xFF009688), // sarcelle
    Color(0xFF0F9D58), // vert
    Color(0xFFEF6C00), // orange
    Color(0xFF795548), // brun
    Color(0xFF607D8B), // gris bleu
  ];
}

/// Tokens sémantiques exposés à l'UI via `context.appColors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceField,
    required this.outline,
    required this.textPrimary,
    required this.textMuted,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.onAccentSoft,
    required this.fabBackground,
    required this.onFab,
    required this.selection,
    required this.star,
    required this.danger,
  });

  final Color background;
  final Color surface;

  /// Fond des blocs posés sur la surface (cartes de suggestion, en-têtes).
  final Color surfaceAlt;

  /// Fond des champs de saisie et de la barre de recherche.
  final Color surfaceField;

  final Color outline;
  final Color textPrimary;
  final Color textMuted;
  final Color accent;
  final Color onAccent;
  final Color accentSoft;
  final Color onAccentSoft;

  /// Le bouton flottant de Google Contacts est bleu clair, pas bleu vif.
  final Color fabBackground;
  final Color onFab;

  /// Fond d'une ligne sélectionnée (sélection multiple).
  final Color selection;

  final Color star;
  final Color danger;

  /// Couleur de la pastille d'initiales pour un index donné.
  Color avatar(int index) => ContactsPalette.avatars[index % ContactsPalette.avatars.length];

  static const AppColors light = AppColors(
    background: ContactsPalette.white,
    surface: ContactsPalette.white,
    surfaceAlt: ContactsPalette.grey50,
    surfaceField: ContactsPalette.grey100,
    outline: ContactsPalette.outlineLight,
    textPrimary: ContactsPalette.ink,
    textMuted: ContactsPalette.inkMuted,
    accent: ContactsPalette.blue,
    onAccent: ContactsPalette.white,
    accentSoft: ContactsPalette.blueSoft,
    onAccentSoft: ContactsPalette.blue,
    fabBackground: ContactsPalette.blueContainer,
    onFab: ContactsPalette.onBlueContainer,
    selection: ContactsPalette.blueSoft,
    star: ContactsPalette.star,
    danger: ContactsPalette.red,
  );

  static const AppColors dark = AppColors(
    background: ContactsPalette.grey900,
    surface: ContactsPalette.grey850,
    surfaceAlt: ContactsPalette.grey850,
    surfaceField: ContactsPalette.grey800,
    outline: ContactsPalette.outlineDark,
    textPrimary: ContactsPalette.inkInverse,
    textMuted: ContactsPalette.inkMutedInverse,
    accent: ContactsPalette.blueLight,
    onAccent: ContactsPalette.grey900,
    accentSoft: ContactsPalette.blueSoftDark,
    onAccentSoft: ContactsPalette.blueLight,
    fabBackground: ContactsPalette.blueContainerDark,
    onFab: ContactsPalette.onBlueContainerDark,
    selection: ContactsPalette.blueSoftDark,
    star: ContactsPalette.star,
    danger: ContactsPalette.redLight,
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? surfaceField,
    Color? outline,
    Color? textPrimary,
    Color? textMuted,
    Color? accent,
    Color? onAccent,
    Color? accentSoft,
    Color? onAccentSoft,
    Color? fabBackground,
    Color? onFab,
    Color? selection,
    Color? star,
    Color? danger,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      surfaceField: surfaceField ?? this.surfaceField,
      outline: outline ?? this.outline,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentSoft: accentSoft ?? this.accentSoft,
      onAccentSoft: onAccentSoft ?? this.onAccentSoft,
      fabBackground: fabBackground ?? this.fabBackground,
      onFab: onFab ?? this.onFab,
      selection: selection ?? this.selection,
      star: star ?? this.star,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      surfaceField: Color.lerp(surfaceField, other.surfaceField, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      onAccentSoft: Color.lerp(onAccentSoft, other.onAccentSoft, t)!,
      fabBackground: Color.lerp(fabBackground, other.fabBackground, t)!,
      onFab: Color.lerp(onFab, other.onFab, t)!,
      selection: Color.lerp(selection, other.selection, t)!,
      star: Color.lerp(star, other.star, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

/// Raccourci d'accès : `context.appColors.accent`.
extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}

/// Schémas Material 3 — bleu Google en `primary`.
final ColorScheme contactsLightScheme = ColorScheme.fromSeed(seedColor: ContactsPalette.blue)
    .copyWith(
      primary: ContactsPalette.blue,
      onPrimary: ContactsPalette.white,
      primaryContainer: ContactsPalette.blueContainer,
      onPrimaryContainer: ContactsPalette.onBlueContainer,
      secondaryContainer: ContactsPalette.blueSoft,
      onSecondaryContainer: ContactsPalette.blue,
      surface: ContactsPalette.white,
      onSurface: ContactsPalette.ink,
      onSurfaceVariant: ContactsPalette.inkMuted,
      surfaceContainerHighest: ContactsPalette.grey100,
      outline: ContactsPalette.outlineLight,
      outlineVariant: ContactsPalette.grey200,
      error: ContactsPalette.red,
    );

final ColorScheme contactsDarkScheme =
    ColorScheme.fromSeed(seedColor: ContactsPalette.blue, brightness: Brightness.dark).copyWith(
      primary: ContactsPalette.blueLight,
      onPrimary: ContactsPalette.grey900,
      primaryContainer: ContactsPalette.blueContainerDark,
      onPrimaryContainer: ContactsPalette.onBlueContainerDark,
      secondaryContainer: ContactsPalette.blueSoftDark,
      onSecondaryContainer: ContactsPalette.blueLight,
      surface: ContactsPalette.grey850,
      onSurface: ContactsPalette.inkInverse,
      onSurfaceVariant: ContactsPalette.inkMutedInverse,
      surfaceContainerHighest: ContactsPalette.grey800,
      outline: ContactsPalette.outlineDark,
      outlineVariant: ContactsPalette.grey750,
      error: ContactsPalette.redLight,
    );
