import 'package:contacts/core/application/dtos/contact_summary.dto.dart';
import 'package:contacts/core/application/services/contact_grouping.service.dart';
import 'package:contacts/core/application/services/text_normalizer.service.dart';
import 'package:flutter_test/flutter_test.dart';

ContactSummaryDto _summary(String name, {bool starred = false}) => ContactSummaryDto(
  id: name,
  displayName: name,
  subtitle: '',
  initials: name.isEmpty ? '' : name[0],
  sectionKey: TextNormalizer.sectionKey(name),
  sortKey: TextNormalizer.normalize(name),
  starred: starred,
);

void main() {
  group('TextNormalizer', () {
    test('range les accents avec leur lettre de base', () {
      expect(TextNormalizer.sectionKey('Élodie'), 'E');
      expect(TextNormalizer.normalize('Éric'), 'eric');
    });

    test('regroupe sous « # » ce qui ne commence pas par une lettre', () {
      expect(TextNormalizer.sectionKey('4 Roues'), '#');
      expect(TextNormalizer.sectionKey('+33 6 12'), '#');
      expect(TextNormalizer.sectionKey(''), '#');
    });
  });

  group('ContactGrouping', () {
    test('épingle les favoris en tête, puis range par initiale', () {
      final sections = ContactGrouping.sections([
        _summary('Bruno'),
        _summary('Alice', starred: true),
        _summary('Élodie'),
      ]);

      expect(sections.first.header, 'Favoris');
      expect(sections.first.contacts.single.displayName, 'Alice');
      expect([for (final s in sections.skip(1)) s.header], ['A', 'B', 'E']);
    });

    test('n\'épingle rien quand la vue est déjà filtrée', () {
      final sections = ContactGrouping.sections([
        _summary('Alice', starred: true),
      ], pinFavorites: false);
      expect(sections.single.header, 'A');
    });

    test('renvoie la section « # » en dernier', () {
      final sections = ContactGrouping.sections([_summary('4 Roues'), _summary('Zoé')]);
      expect([for (final s in sections) s.header], ['Z', '#']);
    });

    test('l\'index latéral ignore la section des favoris', () {
      final sections = ContactGrouping.sections([_summary('Alice', starred: true)]);
      expect(ContactGrouping.alphabetIndex(sections), ['A']);
    });
  });
}
