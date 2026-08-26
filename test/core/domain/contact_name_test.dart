import 'package:contacts/core/domain/model/contact.dart';
import 'package:contacts/core/domain/model/contact_name.dart';
import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/core/domain/model/entity_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContactName', () {
    test('assemble le nom complet dans l\'ordre naturel', () {
      const name = ContactName(
        prefix: 'Dr',
        first: 'Jean',
        middle: 'Paul',
        last: 'Martin',
        suffix: 'Jr',
      );
      expect(name.fullName, 'Dr Jean Paul Martin Jr');
    });

    test('inverse nom et prénom quand le format le demande', () {
      const name = ContactName(first: 'Jean', last: 'Martin');
      expect(name.displayName(NameFormat.prenomNom), 'Jean Martin');
      expect(name.displayName(NameFormat.nomPrenom), 'Martin, Jean');
    });

    test('garde l\'ordre naturel si l\'un des deux champs manque', () {
      const name = ContactName(first: 'Cher');
      expect(name.displayName(NameFormat.nomPrenom), 'Cher');
    });

    test('retombe sur le surnom quand il n\'y a pas de nom', () {
      const name = ContactName(nickname: 'Le Chef');
      expect(name.displayName(NameFormat.prenomNom), 'Le Chef');
      expect(name.isEmpty, isFalse);
    });

    test('prend deux initiales quand prénom et nom sont connus, une sinon', () {
      expect(const ContactName(first: 'Jean', last: 'Martin').initials, 'JM');
      expect(const ContactName(first: 'Jean').initials, 'J');
      expect(const ContactName().initials, '');
    });

    test('bascule sur l\'autre champ quand la clé de tri demandée est vide', () {
      const monoNom = ContactName(last: 'Martin');
      expect(monoNom.sortKey(ContactSortOrder.prenom), 'Martin');
      expect(monoNom.sortKey(ContactSortOrder.nom), 'Martin');
    });
  });

  group('Contact', () {
    Contact build({ContactName name = ContactName.empty, String? company, String? jobTitle}) =>
        Contact(
          id: EntityId.generate(),
          name: name,
          company: company,
          jobTitle: jobTitle,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        );

    test('une fiche sans nom se présente par sa société', () {
      final contact = build(company: 'Garage Delaunay');

      expect(contact.displayName(NameFormat.prenomNom), 'Garage Delaunay');
      expect(contact.initials, 'G');
    });

    test('ne répète pas la société quand elle sert déjà de nom', () {
      expect(build(company: 'Garage Delaunay').subtitle, '');
      expect(build(company: 'Garage Delaunay', jobTitle: 'Carrosserie').subtitle, 'Carrosserie');
    });

    test('annonce poste et société pour une personne', () {
      final contact = build(
        name: const ContactName(first: 'Camille', last: 'Bernard'),
        company: 'Atelier Bernard',
        jobTitle: 'Architecte',
      );

      expect(contact.subtitle, 'Architecte, Atelier Bernard');
    });
  });
}
