import 'package:contacts/core/application/dtos/contact_summary.dto.dart';

/// Une tranche de la liste : une lettre d'index et les contacts qu'elle porte.
class ContactSectionDto {
  /// Libellé affiché en tête de section (« A », « # »).
  final String header;

  final List<ContactSummaryDto> contacts;

  const ContactSectionDto({required this.header, required this.contacts});
}
