import 'package:contacts/core/application/services/vcard.service.dart';
import 'package:contacts/core/domain/exceptions/contact_exception.dart';
import 'package:contacts/core/domain/model/contact.dart';
import 'package:contacts/core/domain/model/contact_event.dart';
import 'package:contacts/core/domain/model/contact_label.dart';
import 'package:contacts/core/domain/model/contact_name.dart';
import 'package:contacts/core/domain/model/email_address.dart';
import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/core/domain/model/phone_number.dart';
import 'package:contacts/core/domain/model/postal_address.dart';
import 'package:contacts/core/domain/model/uuid_value.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures.dart';

void main() {
  group('VCard export', () {
    test('écrit une fiche complète en vCard 3.0', () {
      final contact = Contact(
        id: UuidValue.generate(),
        name: const ContactName(first: 'Marie', last: 'Dupont'),
        company: 'BNP Paribas',
        jobTitle: 'Conseillère',
        phones: [PhoneNumber.create('06 12 34 56 78')],
        emails: [EmailAddress.create('marie@bnp.fr', type: EmailType.professionnel)],
        addresses: [
          PostalAddress.create(street: '5 rue de Paris', postcode: '75001', city: 'Paris'),
        ],
        events: [ContactEvent.create(day: 14, month: 3, year: 1987)],
        starred: true,
        createdAt: testNow,
        updatedAt: testNow,
      );

      final vcf = VCard.exportOne(contact);

      expect(vcf, contains('BEGIN:VCARD\r\nVERSION:3.0'));
      expect(vcf, contains('N:Dupont;Marie;;;'));
      expect(vcf, contains('FN:Marie Dupont'));
      expect(vcf, contains('TEL;TYPE=CELL:06 12 34 56 78'));
      expect(vcf, contains('EMAIL;TYPE=WORK:marie@bnp.fr'));
      expect(vcf, contains('BDAY:1987-03-14'));
      expect(vcf, contains('X-GOOGLE-STARRED:true'));
      expect(vcf.trimRight(), endsWith('END:VCARD'));
    });

    test('cite les étiquettes du contact dans CATEGORIES', () {
      final label = ContactLabel.create('Travail', now: testNow);
      final contact = aContact(first: 'Marie', labelIds: {label.id});

      expect(VCard.exportOne(contact, labels: [label]), contains('CATEGORIES:Travail'));
    });
  });

  group('VCard import', () {
    test('relit ce qu\'il a écrit', () {
      final original = Contact(
        id: UuidValue.generate(),
        name: const ContactName(first: 'Élodie', last: 'Charpentier', nickname: 'Élo'),
        company: 'Clinique du Parc',
        jobTitle: 'Kinésithérapeute',
        phones: [
          PhoneNumber.create('06 12 34 56 78'),
          PhoneNumber.create('01 45 67 89 01', type: PhoneType.professionnel),
        ],
        emails: [EmailAddress.create('elodie@clinique.fr', type: EmailType.professionnel)],
        addresses: [
          PostalAddress.create(
            street: '32 cours Victor Hugo',
            postcode: '33000',
            city: 'Bordeaux',
            country: 'France',
          ),
        ],
        events: [ContactEvent.create(day: 2, month: 9, year: 1990)],
        notes: 'Cabinet fermé le lundi',
        createdAt: testNow,
        updatedAt: testNow,
      );

      final reread = VCard.parse(VCard.exportOne(original), now: testNow).single.contact;

      expect(reread.name.first, 'Élodie');
      expect(reread.name.last, 'Charpentier');
      expect(reread.name.nickname, 'Élo');
      expect(reread.company, 'Clinique du Parc');
      expect(reread.jobTitle, 'Kinésithérapeute');
      expect(reread.phones.map((p) => p.value), ['06 12 34 56 78', '01 45 67 89 01']);
      expect(reread.phones.last.type, PhoneType.professionnel);
      expect(reread.emails.single.type, EmailType.professionnel);
      expect(reread.addresses.single.city, 'Bordeaux');
      expect(reread.addresses.single.postcode, '33000');
      expect(reread.birthday?.year, 1990);
      expect(reread.notes, 'Cabinet fermé le lundi');
    });

    test('conserve un libellé personnalisé via X-ABLabel', () {
      final contact = Contact(
        id: UuidValue.generate(),
        name: const ContactName(first: 'Pierre'),
        phones: [
          PhoneNumber.create(
            '06 45 78 91 23',
            type: PhoneType.personnalise,
            customLabel: 'Maison de campagne',
          ),
        ],
        createdAt: testNow,
        updatedAt: testNow,
      );

      final reread = VCard.parse(VCard.exportOne(contact), now: testNow).single.contact;

      expect(reread.phones.single.type, PhoneType.personnalise);
      expect(reread.phones.single.label, 'Maison de campagne');
    });

    test('lit une fiche qui n\'a qu\'un FN', () {
      const source = 'BEGIN:VCARD\r\nVERSION:3.0\r\nFN:Jean Martin\r\nEND:VCARD\r\n';

      final contact = VCard.parse(source, now: testNow).single.contact;

      expect(contact.name.first, 'Jean');
      expect(contact.name.last, 'Martin');
    });

    test('lit une date de naissance sans année', () {
      const source = 'BEGIN:VCARD\r\nVERSION:3.0\r\nFN:Amina\r\nBDAY:--06-27\r\nEND:VCARD\r\n';

      final birthday = VCard.parse(source, now: testNow).single.contact.birthday!;

      expect(birthday.year, isNull);
      expect(birthday.month, 6);
      expect(birthday.day, 27);
    });

    test('déplie les lignes de continuation', () {
      const source =
          'BEGIN:VCARD\r\nVERSION:3.0\r\nNOTE:Une note vraiment tr\r\n'
          ' es longue\r\nFN:Test\r\nEND:VCARD\r\n';

      expect(
        VCard.parse(source, now: testNow).single.contact.notes,
        'Une note vraiment tres longue',
      );
    });

    test('lit plusieurs fiches d\'un même fichier et remonte les étiquettes', () {
      final label = ContactLabel.create('Amis', now: testNow);
      final source = VCard.export(
        [
          aContact(first: 'A', labelIds: {label.id}),
          aContact(first: 'B'),
        ],
        labels: [label],
      );

      final parsed = VCard.parse(source, now: testNow);

      expect(parsed.length, 2);
      expect(parsed.first.labelNames, ['Amis']);
      expect(parsed.last.labelNames, isEmpty);
    });

    test('refuse un fichier qui n\'est pas une vCard', () {
      expect(() => VCard.parse('nom;prenom\r\nDupont;Marie'), throwsA(isA<VCardParseException>()));
    });

    test('conserve les séparateurs échappés', () {
      final contact = aContact(first: 'Test', notes: 'Ligne 1;avec, virgule');

      final reread = VCard.parse(VCard.exportOne(contact), now: testNow).single.contact;

      expect(reread.notes, 'Ligne 1;avec, virgule');
    });
  });
}
