import 'package:contacts/core/application/dtos/contact_section.dto.dart';
import 'package:contacts/core/application/dtos/contact_summary.dto.dart';

/// La liste de contacts telle que l'écran d'accueil l'affiche : les sections,
/// et de quoi remplir la barre de titre (« 42 contacts ») et l'index latéral.
class ContactListDto {
  final List<ContactSectionDto> sections;

  /// Tous les contacts, à plat et déjà triés — sert à la sélection multiple
  /// (« Tout sélectionner ») sans reparcourir les sections.
  final List<ContactSummaryDto> all;

  /// Lettres de l'index alphabétique latéral, dans l'ordre d'apparition.
  final List<String> alphabet;

  const ContactListDto({
    required this.sections,
    required this.all,
    required this.alphabet,
  });

  static const empty = ContactListDto(sections: [], all: [], alphabet: []);

  int get total => all.length;

  bool get isEmpty => all.isEmpty;
}
