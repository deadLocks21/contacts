import 'package:contacts/core/application/usecases/delete_forever.usecase.dart';
import 'package:contacts/core/application/usecases/export_vcard.usecase.dart';
import 'package:contacts/core/application/usecases/import_vcard.usecase.dart';
import 'package:contacts/core/application/usecases/list_duplicates.usecase.dart';
import 'package:contacts/core/application/usecases/list_trash.usecase.dart';
import 'package:contacts/core/application/usecases/merge_contacts.usecase.dart';
import 'package:contacts/core/application/usecases/move_to_trash.usecase.dart';
import 'package:contacts/core/application/usecases/purge_expired_trash.usecase.dart';
import 'package:contacts/core/application/usecases/restore_from_trash.usecase.dart';
import 'package:contacts/core/domain/model/app_settings.dart';
import 'package:contacts/core/domain/model/contact.dart';
import 'package:contacts/core/domain/model/contact_label.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures.dart';
import '../../../support/harness.dart';

void main() {
  late Harness harness;

  setUp(() => harness = Harness());

  const settings = AppSettings.defaults;

  group('Corbeille', () {
    test('supprimer met à la corbeille sans effacer', () async {
      final contact = aContact(first: 'Marie');
      await harness.contacts.save(contact);

      await MoveToTrashUseCase(harness.contacts).execute([contact.id.value], now: testNow);

      expect(await harness.contacts.listAll(), isEmpty);
      expect((await harness.contacts.listTrashed()).single.id, contact.id);
    });

    test('annonce le temps restant avant purge', () async {
      await harness.contacts.save(aContact(first: 'Marie', deletedAt: testNow));

      final entries = await ListTrashUseCase(harness.contacts)
          .execute(settings: settings, now: testNow.add(const Duration(days: 18)));

      expect(entries.single.daysLeft, 12);
      expect(entries.single.countdown, 'Suppression définitive dans 12 jours');
    });

    test('restaurer remet la fiche dans le carnet', () async {
      final contact = aContact(first: 'Marie', deletedAt: testNow);
      await harness.contacts.save(contact);

      await RestoreFromTrashUseCase(harness.contacts).execute([contact.id.value], now: testNow);

      expect((await harness.contacts.listAll()).single.id, contact.id);
      expect(await harness.contacts.listTrashed(), isEmpty);
    });

    test('la suppression définitive efface aussi la photo devenue orpheline', () async {
      final contact = aContact(first: 'Marie').copyWith(photoPath: '/photos/marie.jpg');
      await harness.contacts.save(contact);

      await DeleteForeverUseCase(harness.contacts, harness.photos).execute([contact.id.value]);

      expect(await harness.contacts.listAll(includeTrashed: true), isEmpty);
      expect(harness.photos.removed, ['/photos/marie.jpg']);
    });

    test('purge ce qui a dépassé trente jours, et rien d\'autre', () async {
      await harness.contacts.saveAll([
        aContact(first: 'Vieux', deletedAt: testNow.subtract(const Duration(days: 31))),
        aContact(first: 'Récent', deletedAt: testNow.subtract(const Duration(days: 3))),
      ]);

      final purged = await PurgeExpiredTrashUseCase(harness.contacts, harness.photos)
          .execute(now: testNow);

      expect(purged, 1);
      expect((await harness.contacts.listTrashed()).single.name.first, 'Récent');
    });
  });

  group('Doublons', () {
    test('rapproche deux fiches par le numéro, quelle que soit son écriture', () async {
      await harness.contacts.saveAll([
        aContact(first: 'Julien', last: 'Mercier', phones: ['06 88 21 45 63']),
        aContact(first: 'Julien', phones: ['+33 6 88 21 45 63']),
      ]);

      final groups = await ListDuplicatesUseCase(harness.contacts).execute(settings: settings);

      expect(groups.single.contacts.length, 2);
      expect(groups.single.reason.label, 'Même numéro de téléphone');
    });

    test('ne signale une paire qu\'une fois, par son critère le plus sûr', () async {
      await harness.contacts.saveAll([
        aContact(first: 'Marie', last: 'Dupont', phones: ['0612345678'], emails: ['m@d.fr']),
        aContact(first: 'Marie', last: 'Dupont', phones: ['0612345678'], emails: ['m@d.fr']),
      ]);

      final groups = await ListDuplicatesUseCase(harness.contacts).execute(settings: settings);

      expect(groups.length, 1);
      expect(groups.single.reason.label, 'Même adresse e-mail');
    });

    test('fusionner ne laisse qu\'une fiche, enrichie', () async {
      final ancienne = aContact(
        first: 'Julien',
        last: 'Mercier',
        phones: ['06 88 21 45 63'],
        createdAt: DateTime.utc(2024),
      );
      final recente = aContact(
        first: 'Julien',
        company: 'Studio Nord',
        emails: ['j@studionord.io'],
        createdAt: DateTime.utc(2026),
      );
      await harness.contacts.saveAll([ancienne, recente]);

      final id = await MergeContactsUseCase(harness.contacts)
          .execute([ancienne.id.value, recente.id.value], now: testNow);

      final all = await harness.contacts.listAll();
      expect(all.length, 1);
      expect(id, ancienne.id.value);
      expect(all.single.company, 'Studio Nord');
      expect(all.single.emails.single.value, 'j@studionord.io');
      expect(all.single.phones.single.value, '06 88 21 45 63');
    });
  });

  group('Import / export vCard', () {
    test('exporte tout le carnet, corbeille exclue', () async {
      await harness.contacts.saveAll([
        aContact(first: 'Marie'),
        aContact(first: 'Fantôme', deletedAt: testNow),
      ]);

      final vcf = await ExportVCardUseCase(harness.contacts, harness.labels).execute();

      expect('BEGIN:VCARD'.allMatches(vcf).length, 1);
      expect(vcf, contains('FN:Marie'));
    });

    test('exporte une sélection', () async {
      final marie = aContact(first: 'Marie');
      await harness.contacts.saveAll([marie, aContact(first: 'Marc')]);

      final vcf = await ExportVCardUseCase(harness.contacts, harness.labels)
          .execute(ids: [marie.id.value]);

      expect(vcf, contains('FN:Marie'));
      expect(vcf, isNot(contains('FN:Marc')));
    });

    test('importe en ajoutant, sans toucher à l\'existant', () async {
      await harness.contacts.save(aContact(first: 'Déjà là'));
      const source = 'BEGIN:VCARD\r\nVERSION:3.0\r\nFN:Nouveau Venu\r\nEND:VCARD\r\n';

      final report =
          await ImportVCardUseCase(harness.contacts, harness.labels).execute(source, now: testNow);

      expect(report.imported, 1);
      expect((await harness.contacts.listAll()).length, 2);
    });

    test('crée les étiquettes citées qui n\'existent pas encore', () async {
      const source = 'BEGIN:VCARD\r\nVERSION:3.0\r\nFN:Marie\r\nCATEGORIES:Travail,Amis\r\n'
          'END:VCARD\r\n';

      final report =
          await ImportVCardUseCase(harness.contacts, harness.labels).execute(source, now: testNow);

      expect(report.labelsCreated, 2);
      final labels = await harness.labels.listAll();
      expect({for (final l in labels) l.name}, {'Travail', 'Amis'});
      final imported = (await harness.contacts.listAll()).single;
      expect(imported.labelIds.length, 2);
    });

    test('réutilise une étiquette existante plutôt que d\'en créer une jumelle', () async {
      await harness.labels.save(ContactLabel.create('Travail', now: testNow));
      const source =
          'BEGIN:VCARD\r\nVERSION:3.0\r\nFN:Marie\r\nCATEGORIES:travail\r\nEND:VCARD\r\n';

      final report =
          await ImportVCardUseCase(harness.contacts, harness.labels).execute(source, now: testNow);

      expect(report.labelsCreated, 0);
      expect((await harness.labels.listAll()).length, 1);
    });

    test('un aller-retour complet conserve le carnet', () async {
      final label = ContactLabel.create('Famille', now: testNow);
      await harness.labels.save(label);
      await harness.contacts.saveAll([
        aContact(first: 'Sophie', last: 'Lambert', phones: ['06 34 56 12 78'], labelIds: {label.id}),
        aContact(first: 'Marc', last: 'Lambert', emails: ['marc@lambert.fr']),
      ]);

      final vcf = await ExportVCardUseCase(harness.contacts, harness.labels).execute();
      final vierge = Harness();
      await ImportVCardUseCase(vierge.contacts, vierge.labels).execute(vcf, now: testNow);

      final reimported = await vierge.contacts.listAll();
      expect(reimported.length, 2);
      final sophie = reimported.firstWhere((c) => c.name.first == 'Sophie');
      expect(sophie.phones.single.value, '06 34 56 12 78');
      expect(sophie.labelIds.length, 1);
      expect((await vierge.labels.listAll()).single.name, 'Famille');
    });
  });
}

