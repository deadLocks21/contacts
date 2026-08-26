import 'package:contacts/core/application/services/text_normalizer.service.dart';

/// Choisit la couleur de la pastille d'initiales d'un contact.
///
/// La couleur doit être **stable** : le même contact garde la sienne d'une
/// session à l'autre, et sur tous les écrans. On la dérive donc du nom (à
/// défaut de l'identifiant) plutôt que d'un tirage.
///
/// L'application ne connaît pas Flutter : elle renvoie un **index** dans la
/// palette, que l'UI traduit en couleur (cf. `AppColors.avatarPalette`).
abstract final class AvatarColor {
  /// Nombre de teintes de la palette — doit rester aligné sur l'UI.
  static const paletteSize = 12;

  static int indexFor(String key) {
    final normalized = TextNormalizer.normalize(key);
    if (normalized.isEmpty) return 0;
    // Hash déterministe (FNV-1a 32 bits) : `String.hashCode` varie d'un
    // lancement à l'autre, la couleur changerait à chaque démarrage.
    var hash = 0x811c9dc5;
    for (final unit in normalized.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash % paletteSize;
  }
}
