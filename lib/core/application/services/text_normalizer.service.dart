import 'package:diacritic/diacritic.dart';

/// Normalisation du texte pour le tri, l'indexation alphabétique et la
/// recherche : sans accent, sans casse, sans espaces superflus.
///
/// Sans elle, « Élodie » se rangerait après « Zoé » et une recherche sur
/// « eric » ne trouverait pas « Éric ».
abstract final class TextNormalizer {
  static String normalize(String input) => removeDiacritics(input.trim().toLowerCase());

  /// Lettre de section pour l'index alphabétique. Tout ce qui ne commence pas
  /// par une lettre (chiffres, symboles, idéogrammes) tombe sous « # », comme
  /// dans Google Contacts.
  static String sectionKey(String input) {
    final normalized = normalize(input);
    if (normalized.isEmpty) return '#';
    final first = normalized[0].toUpperCase();
    return RegExp(r'^[A-Z]$').hasMatch(first) ? first : '#';
  }

  /// Découpe une requête en mots — chacun devra être retrouvé dans la fiche
  /// (« mar dup » trouve « Marie Dupont »).
  static List<String> tokenize(String query) =>
      normalize(query).split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

  /// Chiffres seuls — pour comparer des numéros écrits différemment.
  static String digitsOnly(String input) => input.replaceAll(RegExp(r'\D'), '');
}
