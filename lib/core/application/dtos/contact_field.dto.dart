/// Une ligne d'information de la fiche : un libellé (« Mobile », « Domicile »),
/// une valeur affichée, et de quoi déclencher l'action associée.
class ContactFieldDto {
  final String id;

  /// Libellé résolu — le libellé personnalisé s'il y en a un, sinon celui du type.
  final String label;

  /// Valeur telle qu'affichée (numéro mis en forme, adresse multi-lignes…).
  final String value;

  /// Valeur brute pour l'action (numéro sans espaces, URL absolue…).
  final String rawValue;

  const ContactFieldDto({
    required this.id,
    required this.label,
    required this.value,
    required this.rawValue,
  });
}
