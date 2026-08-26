import 'package:contacts/core/application/dtos/contact_section.dto.dart';
import 'package:contacts/core/application/dtos/contact_summary.dto.dart';

/// Découpe la liste de contacts en sections affichables.
///
/// Google Contacts épingle les favoris en tête, puis range le reste par
/// initiale. Les sections « # » (ce qui ne commence pas par une lettre)
/// ferment la liste.
abstract final class ContactGrouping {
  /// En-tête de la section épinglée des favoris.
  static const favoritesHeader = 'Favoris';

  static List<ContactSectionDto> sections(
    List<ContactSummaryDto> contacts, {
    bool pinFavorites = true,
  }) {
    final sorted = [...contacts]..sort(compare);
    final sections = <ContactSectionDto>[];

    if (pinFavorites) {
      final favorites = sorted.where((c) => c.starred).toList();
      if (favorites.isNotEmpty) {
        sections.add(ContactSectionDto(
          header: favoritesHeader,
          contacts: favorites,
          isFavorites: true,
        ));
      }
    }

    final grouped = <String, List<ContactSummaryDto>>{};
    for (final contact in sorted) {
      grouped.putIfAbsent(contact.sectionKey, () => []).add(contact);
    }

    final keys = grouped.keys.toList()..sort(_compareSectionKeys);
    for (final key in keys) {
      sections.add(ContactSectionDto(header: key, contacts: grouped[key]!));
    }
    return sections;
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
  /// l'ordre où elles apparaissent (favoris exclus).
  static List<String> alphabetIndex(List<ContactSectionDto> sections) =>
      [for (final s in sections) if (!s.isFavorites) s.header];
}
