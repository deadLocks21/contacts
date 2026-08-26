import 'package:contacts/core/application/dtos/contact_draft.dto.dart';
import 'package:contacts/core/application/usecases/get_contact.usecase.dart';
import 'package:contacts/core/application/usecases/list_contacts.usecase.dart';
import 'package:contacts/core/application/usecases/load_contact_draft.usecase.dart';
import 'package:contacts/core/application/usecases/save_contact.usecase.dart';
import 'package:contacts/core/application/usecases/search_contacts.usecase.dart';
import 'package:contacts/core/application/usecases/toggle_star.usecase.dart';
import 'package:contacts/core/domain/exceptions/contact_exception.dart';
import 'package:contacts/core/domain/model/app_settings.dart';
import 'package:contacts/core/domain/model/contact_label.dart';
import 'package:contacts/core/domain/model/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures.dart';
import '../../../support/harness.dart';

void main() {
  late Harness harness;

  setUp(() => harness = Harness());

  const settings = AppSettings.defaults;

  group('ListContactsUseCase', () {
    test('découpe la liste en sections, favoris en tête', () async {
      await harness.contacts.saveAll([
        aContact(first: 'Bruno', last: 'Alric'),
        aContact(first: 'Alice', last: 'Zola', starred: true),
      ]);

      final list = await ListContactsUseCase(harness.contacts).execute(settings: settings);

      expect(list.total, 2);
      expect(list.sections.first.header, 'Favoris');
      expect(list.alphabet, ['A', 'B']);
    });

    test('range selon le critère de tri choisi', () async {
      await harness.contacts.saveAll([
        aContact(first: 'Bruno', last: 'Alric'),
        aContact(first: 'Alice', last: 'Zola'),
      ]);

      final parNom = await ListContactsUseCase(harness.contacts)
          .execute(settings: settings.copyWith(sortOrder: ContactSortOrder.nom));

      expect([for (final c in parNom.all) c.displayName], ['Bruno Alric', 'Alice Zola']);
    });

    test('exclut la corbeille', () async {
      await harness.contacts.saveAll([
        aContact(first: 'Visible'),
        aContact(first: 'Supprimé', deletedAt: testNow),
      ]);

      final list = await ListContactsUseCase(harness.contacts).execute(settings: settings);

      expect(list.total, 1);
    });

    test('filtre sur une étiquette', () async {
      final travail = ContactLabel.create('Travail', now: testNow);
      await harness.labels.save(travail);
      await harness.contacts.saveAll([
        aContact(first: 'Collègue', labelIds: {travail.id}),
        aContact(first: 'Autre'),
      ]);

      final list = await ListContactsUseCase(harness.contacts)
          .execute(settings: settings, labelId: travail.id.value);

      expect([for (final c in list.all) c.displayName], ['Collègue']);
    });

    test('la vue « Favoris » ne réépingle pas de section Favoris', () async {
      await harness.contacts.saveAll([
        aContact(first: 'Marqué', starred: true),
        aContact(first: 'Autre'),
      ]);

      final list = await ListContactsUseCase(harness.contacts)
          .execute(settings: settings, starredOnly: true);

      expect(list.total, 1);
      expect(list.sections.single.isFavorites, isFalse);
    });
  });

  group('SaveContactUseCase', () {
    test('crée une fiche à partir du formulaire', () async {
      final draft = ContactDraft.blank()
        ..first = 'Marie'
        ..last = 'Dupont';
      draft.phones.first.value = '06 12 34 56 78';

      final id = await SaveContactUseCase(harness.contacts).execute(draft, now: testNow);

      final saved = await harness.contacts.getById(id);
      expect(saved!.name.first, 'Marie');
      expect(saved.phones.single.value, '06 12 34 56 78');
    });

    test('écarte les lignes laissées vides', () async {
      final draft = ContactDraft.blank()..first = 'Marie';

      final id = await SaveContactUseCase(harness.contacts).execute(draft, now: testNow);

      final saved = await harness.contacts.getById(id);
      expect(saved!.phones, isEmpty);
      expect(saved.emails, isEmpty);
    });

    test('refuse un formulaire entièrement vide', () async {
      expect(
        () => SaveContactUseCase(harness.contacts).execute(ContactDraft.blank(), now: testNow),
        throwsA(isA<BlankContactException>()),
      );
    });

    test('permet de vider un champ existant', () async {
      final contact = aContact(first: 'Marie', company: 'BNP');
      await harness.contacts.save(contact);

      final draft = await LoadContactDraftUseCase(harness.contacts)
          .execute(contactId: contact.id.value)
        ..company = '';
      await SaveContactUseCase(harness.contacts).execute(draft, now: testNow);

      expect((await harness.contacts.getById(contact.id.value))!.company, isNull);
    });

    test('conserve identifiant, création et favori lors d\'une modification', () async {
      final contact = aContact(first: 'Marie', starred: true, createdAt: DateTime.utc(2024));
      await harness.contacts.save(contact);

      final draft = await LoadContactDraftUseCase(harness.contacts)
          .execute(contactId: contact.id.value)
        ..last = 'Dupont';
      final id = await SaveContactUseCase(harness.contacts).execute(draft, now: testNow);

      final saved = await harness.contacts.getById(id);
      expect(id, contact.id.value);
      expect(saved!.createdAt.toUtc(), DateTime.utc(2024));
      expect(saved.starred, isTrue);
    });
  });

  group('GetContactUseCase', () {
    test('met en forme numéros et dates pour l\'affichage', () async {
      final contact = aContact(first: 'Marie', phones: ['0612345678']);
      await harness.contacts.save(contact);

      final detail = await GetContactUseCase(harness.contacts, harness.labels)
          .execute(contact.id.value, settings: settings);

      expect(detail!.phones.single.value, '06 12 34 56 78');
      expect(detail.phones.single.rawValue, '0612345678');
    });

    test('rend null pour une fiche disparue', () async {
      final detail = await GetContactUseCase(harness.contacts, harness.labels)
          .execute('00000000-0000-4000-8000-000000000000', settings: settings);

      expect(detail, isNull);
    });
  });

  group('ToggleStarUseCase', () {
    test('impose le même état à tout le lot', () async {
      final a = aContact(first: 'A', starred: true);
      final b = aContact(first: 'B');
      await harness.contacts.saveAll([a, b]);

      await ToggleStarUseCase(harness.contacts)
          .execute([a.id.value, b.id.value], starred: true, now: testNow);

      final all = await harness.contacts.listAll();
      expect(all.every((c) => c.starred), isTrue);
    });
  });

  group('SearchContactsUseCase', () {
    test('ne cherche pas dans la corbeille', () async {
      await harness.contacts.save(aContact(first: 'Marie', deletedAt: testNow));

      final results =
          await SearchContactsUseCase(harness.contacts).execute('marie', settings: settings);

      expect(results, isEmpty);
    });
  });
}
