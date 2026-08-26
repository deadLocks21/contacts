import 'package:contacts/core/application/dtos/contact_section.dto.dart';
import 'package:contacts/core/application/dtos/contact_summary.dto.dart';

/// Découpe la liste de contacts en sections alphabétiques.
///
/// Les sections « # » (ce qui ne commence pas par une lettre) ferment la
/// liste. Les favoris ne sont pas épinglés ici : ils ont leur propre place
/// dans l'onglet « Faits marquants ».
abstract final class ContactGrouping {
  static List<ContactSectionDto> sections(List<ContactSummaryDto> contacts) {
    final sorted = [...contacts]..sort(compare);

    final grouped = <String, List<ContactSummaryDto>>{};
    for (final contact in sorted) {
      grouped.putIfAbsent(contact.sectionKey, () => []).add(contact);
    }

    final keys = grouped.keys.toList()..sort(_compareSectionKeys);
    return [for (final key in keys) ContactSectionDto(header: key, contacts: grouped[key]!)];
  }

  /// Ordre alphabétique sur la clé normalisée, l'identifiant départageant les
  /// homonymes pour que la liste ne bouge pas d'un affichage à l'autre.
  static int compare(ContactSummaryDto a, ContactSummaryDto b) {
    final byKey = a.sortKey.compareTo(b.sortKey);
    return byKey != 0 ? byKey : a.id.compareTo(b.id);
  }

  /// Les lettres d'abord, « # » en dernier.
  static int _compareSectionKeys(String a, String b) {
    if (a == b) return 0;
    if (a == '#') return 1;
    if (b == '#') return -1;
    return a.compareTo(b);
  }

  /// Index alphabétique latéral : les lettres réellement présentes, dans
  /// l'ordre où elles apparaissent.
  static List<String> alphabetIndex(List<ContactSectionDto> sections) => [
    for (final s in sections) s.header,
  ];
}
