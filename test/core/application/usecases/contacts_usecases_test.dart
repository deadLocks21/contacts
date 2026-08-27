import 'dart:typed_data';

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
    test('découpe la liste en sections alphabétiques', () async {
      await harness.contacts.saveAll([
        aContact(first: 'Bruno', last: 'Alric'),
        aContact(first: 'Alice', last: 'Zola', starred: true),
      ]);

      final list = await ListContactsUseCase(harness.contacts).execute(settings: settings);

      expect(list.total, 2);
      expect([for (final s in list.sections) s.header], ['A', 'B']);
      expect(list.alphabet, ['A', 'B']);
    });

    test('range selon le critère de tri choisi', () async {
      await harness.contacts.saveAll([
        aContact(first: 'Bruno', last: 'Alric'),
        aContact(first: 'Alice', last: 'Zola'),
      ]);

      final parNom = await ListContactsUseCase(
        harness.contacts,
      ).execute(settings: settings.copyWith(sortOrder: ContactSortOrder.nom));

      expect([for (final c in parNom.all) c.displayName], ['Bruno Alric', 'Alice Zola']);
    });

    test('filtre sur une étiquette', () async {
      final travail = ContactLabel.create('Travail', now: testNow);
      await harness.labels.save(travail);
      await harness.contacts.saveAll([
        aContact(first: 'Collègue', labelIds: {travail.id}),
        aContact(first: 'Autre'),
      ]);

      final list = await ListContactsUseCase(
        harness.contacts,
      ).execute(settings: settings, labelId: travail.id.value);

      expect([for (final c in list.all) c.displayName], ['Collègue']);
    });

    test('la vue « Favoris » ne garde que les fiches marquées', () async {
      await harness.contacts.saveAll([
        aContact(first: 'Marqué', starred: true),
        aContact(first: 'Autre'),
      ]);

      final list = await ListContactsUseCase(
        harness.contacts,
      ).execute(settings: settings, starredOnly: true);

      expect([for (final c in list.all) c.displayName], ['Marqué']);
    });

    test('les puces de filtre se cumulent', () async {
      await harness.contacts.saveAll([
        aContact(first: 'Avec tout', phones: ['0612345678'], emails: ['a@b.fr']),
        aContact(first: 'Sans e-mail', phones: ['0612345679']),
        aContact(first: 'Sans rien'),
      ]);

      final list = await ListContactsUseCase(harness.contacts).execute(
        settings: settings,
        filters: {ContactFilter.avecTelephone, ContactFilter.avecEmail},
      );

      expect([for (final c in list.all) c.displayName], ['Avec tout']);
    });
  });

  group('SaveContactUseCase', () {
    test('crée une fiche à partir du formulaire', () async {
      final draft = ContactDraft.blank()
        ..first = 'Marie'
        ..last = 'Dupont';
      draft.phones.first.value = '06 12 34 56 78';

      final id = await SaveContactUseCase(
        harness.contacts,
        harness.logger,
      ).execute(draft, now: testNow);

      final saved = await harness.contacts.getById(id);
      expect(saved!.name.first, 'Marie');
      expect(saved.phones.single.value, '06 12 34 56 78');
    });

    test('écarte les lignes laissées vides', () async {
      final draft = ContactDraft.blank()..first = 'Marie';

      final id = await SaveContactUseCase(
        harness.contacts,
        harness.logger,
      ).execute(draft, now: testNow);

      final saved = await harness.contacts.getById(id);
      expect(saved!.phones, isEmpty);
      expect(saved.emails, isEmpty);
    });

    test('refuse un formulaire entièrement vide', () async {
      expect(
        () => SaveContactUseCase(
          harness.contacts,
          harness.logger,
        ).execute(ContactDraft.blank(), now: testNow),
        throwsA(isA<BlankContactException>()),
      );
    });

    test('permet de vider un champ existant', () async {
      final contact = aContact(first: 'Marie', company: 'BNP');
      await harness.contacts.save(contact);

      final draft =
          await LoadContactDraftUseCase(harness.contacts).execute(contactId: contact.id.value)
            ..company = '';
      await SaveContactUseCase(harness.contacts, harness.logger).execute(draft, now: testNow);

      expect((await harness.contacts.getById(contact.id.value))!.company, isNull);
    });

    test('retirer la photo la retire vraiment de la fiche', () async {
      final contact = aContact(first: 'Marie').copyWith(photo: Uint8List.fromList([1, 2, 3]));
      await harness.contacts.save(contact);

      final draft = await LoadContactDraftUseCase(
        harness.contacts,
      ).execute(contactId: contact.id.value);
      draft.photo = null;
      await SaveContactUseCase(harness.contacts, harness.logger).execute(draft, now: testNow);

      expect((await harness.contacts.getById(contact.id.value))!.photo, isNull);
    });

    test('conserve identifiant, création et favori lors d\'une modification', () async {
      final contact = aContact(first: 'Marie', starred: true, createdAt: DateTime.utc(2024));
      await harness.contacts.save(contact);

      final draft =
          await LoadContactDraftUseCase(harness.contacts).execute(contactId: contact.id.value)
            ..last = 'Dupont';
      final id = await SaveContactUseCase(
        harness.contacts,
        harness.logger,
      ).execute(draft, now: testNow);

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

      final detail = await GetContactUseCase(
        harness.contacts,
        harness.labels,
      ).execute(contact.id.value, settings: settings);

      expect(detail!.phones.single.value, '06 12 34 56 78');
      expect(detail.phones.single.rawValue, '0612345678');
    });

    test('rend null pour une fiche disparue', () async {
      final detail = await GetContactUseCase(
        harness.contacts,
        harness.labels,
      ).execute('00000000-0000-4000-8000-000000000000', settings: settings);

      expect(detail, isNull);
    });
  });

  group('ToggleStarUseCase', () {
    test('impose le même état à tout le lot', () async {
      final a = aContact(first: 'A', starred: true);
      final b = aContact(first: 'B');
      await harness.contacts.saveAll([a, b]);

      await ToggleStarUseCase(
        harness.contacts,
        harness.logger,
      ).execute([a.id.value, b.id.value], starred: true, now: testNow);

      final all = await harness.contacts.listAll();
      expect(all.every((c) => c.starred), isTrue);
    });
  });

  group('SearchContactsUseCase', () {
    test('ne trouve que ce que porte le carnet', () async {
      await harness.contacts.save(aContact(first: 'Marie'));

      expect(
        await SearchContactsUseCase(harness.contacts).execute('marie', settings: settings),
        hasLength(1),
      );
      expect(
        await SearchContactsUseCase(harness.contacts).execute('paul', settings: settings),
        isEmpty,
      );
    });
  });
}
