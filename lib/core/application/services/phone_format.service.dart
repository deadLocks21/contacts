import 'package:contacts/core/application/services/text_normalizer.service.dart';

/// Mise en forme des numéros pour l'affichage.
///
/// On respecte la saisie de l'utilisateur dès qu'elle contient déjà une mise en
/// forme ; on ne regroupe par deux que les numéros français collés, seul cas
/// où le regroupement est certain.
abstract final class PhoneFormat {
  static String display(String raw) {
    final trimmed = raw.trim();
    if (trimmed.contains(' ') || trimmed.contains('.') || trimmed.contains('-')) return trimmed;

    final digits = TextNormalizer.digitsOnly(trimmed);
    // Format national : 06 12 34 56 78
    if (!trimmed.startsWith('+') && digits.length == 10 && digits.startsWith('0')) {
      return _pairs(digits);
    }
    // Format international français : +33 6 12 34 56 78
    if (trimmed.startsWith('+33') && digits.length == 11) {
      return '+33 ${digits[2]} ${_pairs(digits.substring(3))}';
    }
    return trimmed;
  }

  /// Numéro tel que composé : sans espaces ni séparateurs, le « + » conservé.
  static String dialable(String raw) {
    final trimmed = raw.trim();
    final digits = TextNormalizer.digitsOnly(trimmed);
    return trimmed.startsWith('+') ? '+$digits' : digits;
  }

  static String _pairs(String digits) {
    final out = <String>[];
    for (var i = 0; i < digits.length; i += 2) {
      out.add(digits.substring(i, (i + 2).clamp(0, digits.length)));
    }
    return out.join(' ');
  }
}
