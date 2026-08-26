import 'package:contacts/core/application/services/contact_merge.service.dart';
import 'package:contacts/core/domain/model/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures.dart';

void main() {
  group('ContactMerge', () {
    test('garde l\'identifiant et la date de création de la plus ancienne', () {
      final ancienne = aContact(first: 'Julien', createdAt: DateTime.utc(2024));
      final recente = aContact(first: 'Julien', createdAt: DateTime.utc(2026));

      final merged = ContactMerge.merge([recente, ancienne], now: testNow);

      expect(merged.id, ancienne.id);
      expect(merged.createdAt, DateTime.utc(2024));
      expect(ContactMerge.absorbedIds([recente, ancienne]), [recente.id]);
    });

    test('complète les champs manquants sans écraser ceux de la fiche retenue', () {
      final ancienne = aContact(first: 'Julien', last: 'Mercier', createdAt: DateTime.utc(2024));
      final recente = aContact(
        first: 'Julien',
        company: 'Studio Nord',
        createdAt: DateTime.utc(2026),
      );

      final merged = ContactMerge.merge([ancienne, recente], now: testNow);

      expect(merged.name.last, 'Mercier');
      expect(merged.company, 'Studio Nord');
    });

    test('réunit les numéros sans doublon, quelle que soit leur écriture', () {
      final a = aContact(first: 'Julien', phones: ['06 88 21 45 63'], createdAt: DateTime.utc(2024));
      final b = aContact(first: 'Julien', phones: ['0688214563', '07 11 22 33 44'],
          createdAt: DateTime.utc(2026));

      final merged = ContactMerge.merge([a, b], now: testNow);

      expect(merged.phones.length, 2);
      expect(merged.phones.first.value, '06 88 21 45 63');
    });

    test('conserve les notes des deux fiches', () {
      final a = aContact(first: 'A', notes: 'Voisin', createdAt: DateTime.utc(2024));
      final b = aContact(first: 'A', notes: 'Joue au tennis', createdAt: DateTime.utc(2026));

      expect(ContactMerge.merge([a, b], now: testNow).notes, 'Voisin\nJoue au tennis');
    });

    test('la fiche fusionnée est favorite si l\'une des deux l\'était', () {
      final a = aContact(first: 'A', createdAt: DateTime.utc(2024));
      final b = aContact(first: 'A', starred: true, createdAt: DateTime.utc(2026));

      expect(ContactMerge.merge([a, b], now: testNow).starred, isTrue);
    });

    test('dédoublonne les e-mails sans tenir compte de la casse', () {
      final a = aContact(first: 'A', emails: ['Jean@Example.com'], createdAt: DateTime.utc(2024));
      final b = aContact(first: 'A', emails: ['jean@example.com'], createdAt: DateTime.utc(2026));

      final merged = ContactMerge.merge([a, b], now: testNow);
      expect(merged.emails.length, 1);
      expect(merged.emails.single.type, EmailType.domicile);
    });
  });
}
