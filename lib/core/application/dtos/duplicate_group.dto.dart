import 'package:contacts/core/application/dtos/contact_summary.dto.dart';

/// Ce qui a fait rapprocher deux fiches — affiché sous le groupe dans
/// « Fusionner et corriger ».
enum DuplicateReason {
  nom,
  email,
  telephone;

  String get label => switch (this) {
    DuplicateReason.nom => 'Même nom',
    DuplicateReason.email => 'Même adresse e-mail',
    DuplicateReason.telephone => 'Même numéro de téléphone',
  };
}

/// Un groupe de fiches candidates à la fusion.
class DuplicateGroupDto {
  /// Clé stable du groupe (le critère normalisé), pour que l'UI garde son état
  /// d'une recomposition à l'autre.
  final String key;

  final DuplicateReason reason;
  final List<ContactSummaryDto> contacts;

  const DuplicateGroupDto({required this.key, required this.reason, required this.contacts});

  /// Nom mis en avant en tête de groupe.
  String get title => contacts.first.displayName;
}
