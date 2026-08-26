import 'package:contacts/core/application/services/contact_search.service.dart';
import 'package:contacts/core/domain/model/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures.dart';

void main() {
  final marie = aContact(
    first: 'Marie',
    last: 'Dupont',
    company: 'BNP Paribas',
    phones: ['06 12 34 56 78'],
  );
  final marc = aContact(first: 'Marc', last: 'Bernard', emails: ['marc@example.org']);
  final elodie = aContact(first: 'Élodie', last: 'Charpentier', jobTitle: 'Kinésithérapeute');
  final contacts = [marie, marc, elodie];

  List<String> search(String query) => [
    for (final c in ContactSearch.run(contacts, query, nameFormat: NameFormat.prenomNom))
      c.displayName(NameFormat.prenomNom),
  ];

  group('ContactSearch', () {
    test('trouve par début de nom', () {
      expect(search('mar'), ['Marc Bernard', 'Marie Dupont']);
    });

    test('exige que tous les mots correspondent', () {
      expect(search('dupont bnp'), ['Marie Dupont']);
      expect(search('dupont société'), isEmpty);
    });

    test('ignore les accents', () {
      expect(search('elodie'), ['Élodie Charpentier']);
    });

    test('cherche aussi dans la société, le poste et l\'e-mail', () {
      expect(search('paribas'), ['Marie Dupont']);
      expect(search('kine'), ['Élodie Charpentier']);
      expect(search('example.org'), ['Marc Bernard']);
    });

    test('retrouve un numéro écrit autrement que saisi', () {
      expect(search('0612'), ['Marie Dupont']);
    });

    test('classe le nom avant le reste', () {
      final avecSociete = aContact(first: 'Zoé', company: 'Marc & Fils');
      final results = ContactSearch.run(
        [avecSociete, marc],
        'marc',
        nameFormat: NameFormat.prenomNom,
      );
      expect(results.first.displayName(NameFormat.prenomNom), 'Marc Bernard');
    });

    test('rend une liste vide pour une requête vide', () {
      expect(search('   '), isEmpty);
    });
  });
}
