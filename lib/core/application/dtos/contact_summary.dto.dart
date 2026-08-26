import 'package:contacts/core/domain/model/contact.dart';
import 'package:contacts/core/domain/model/enums.dart';

/// Une ligne de la liste de contacts — tout est déjà calculé pour l'affichage.
class ContactSummaryDto {
  final String id;
  final String displayName;

  /// « Poste, Société » — deuxième ligne, vide s'il n'y a rien à dire.
  final String subtitle;
  final String initials;
  final String? photoPath;
  final bool starred;

  /// Lettre de section (« A », « B »… « # » pour ce qui ne commence pas par
  /// une lettre), calculée selon le tri en vigueur.
  final String sectionKey;

  /// Clé de tri normalisée (sans accent, en minuscules).
  final String sortKey;

  const ContactSummaryDto({
    required this.id,
    required this.displayName,
    required this.subtitle,
    required this.initials,
    required this.sectionKey,
    required this.sortKey,
    this.photoPath,
    this.starred = false,
  });

  factory ContactSummaryDto.fromDomain(
    Contact contact, {
    required NameFormat nameFormat,
    required String sectionKey,
    required String sortKey,
  }) => ContactSummaryDto(
    id: contact.id.value,
    displayName: contact.displayName(nameFormat),
    subtitle: contact.subtitle,
    initials: contact.initials,
    photoPath: contact.photoPath,
    starred: contact.starred,
    sectionKey: sectionKey,
    sortKey: sortKey,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactSummaryDto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          displayName == other.displayName &&
          subtitle == other.subtitle &&
          photoPath == other.photoPath &&
          starred == other.starred &&
          sectionKey == other.sectionKey;

  @override
  int get hashCode => Object.hash(id, displayName, subtitle, photoPath, starred, sectionKey);
}
