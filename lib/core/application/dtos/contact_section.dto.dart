import 'package:contacts/core/application/dtos/contact_summary.dto.dart';

/// Une tranche de la liste : un en-tête (« A », « Favoris »…) et ses contacts.
class ContactSectionDto {
  /// Libellé affiché en tête de section.
  final String header;

  final List<ContactSummaryDto> contacts;

  /// Vrai pour la section « Favoris », épinglée en haut de liste et dont
  /// l'en-tête ne fait pas partie de l'index alphabétique latéral.
  final bool isFavorites;

  const ContactSectionDto({required this.header, required this.contacts, this.isFavorites = false});
}
