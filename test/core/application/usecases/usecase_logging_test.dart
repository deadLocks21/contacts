import 'package:contacts/core/application/dtos/contact_draft.dto.dart';
import 'package:contacts/core/application/usecases/apply_label.usecase.dart';
import 'package:contacts/core/application/usecases/create_label.usecase.dart';
import 'package:contacts/core/application/usecases/delete_forever.usecase.dart';
import 'package:contacts/core/application/usecases/import_vcard.usecase.dart';
import 'package:contacts/core/application/usecases/merge_contacts.usecase.dart';
import 'package:contacts/core/application/usecases/move_to_trash.usecase.dart';
import 'package:contacts/core/application/usecases/purge_expired_trash.usecase.dart';
import 'package:contacts/core/application/usecases/restore_from_trash.usecase.dart';
import 'package:contacts/core/application/usecases/save_contact.usecase.dart';
import 'package:contacts/core/application/usecases/toggle_star.usecase.dart';
import 'package:contacts/core/domain/exceptions/contact_exception.dart';
import 'package:contacts/core/domain/model/log_level.dart';
import 'package:contacts/infrastructure/logger/in_memory.logger.service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures.dart';
import '../../../support/harness.dart';

/// Ce que le journal doit dire des opérations du carnet.
///
/// Les messages sont un contrat : ce sont eux qu'on filtre dans Signoz et
/// autour desquels se construisent les alertes. Les renommer par inadvertance
/// ne casse rien à l'exécution — d'où ces tests.
void main() {
  late Harness harness;

  setUp(() => harness = Harness());

  LoggedRecord recordOf(String message) =>
      harness.logs.records.firstWhere((r) => r.message == message);

  group('Fiches', () {
    test('une création dit qu\'elle en est une, avec l\'identifiant alloué', () async {
      final draft = ContactDraft.blank()..first = 'Marie';

      final id = await SaveContactUseCase(
        harness.contacts,
        harness.logger,
      ).execute(draft, now: testNow);

      final record = recordOf('contact.saved');
      expect(record.level, LogLevel.info);
      expect(record.attributes['contact.id'], id);
      expect(record.attributes['contact.created'], isTrue);
    });

    test('une modification se distingue d\'une création', () async {
      final contact = aContact(first: 'Marie');
      await harness.contacts.save(contact);
      final draft = ContactDraft.fromDomain(contact)..last = 'Dupont';

      await SaveContactUseCase(harness.contacts, harness.logger).execute(draft, now: testNow);

      expect(recordOf('contact.saved').attributes['contact.created'], isFalse);
    });

    test('un formulaire vide laisse une trace, pas seulement une exception', () async {
      await expectLater(
        SaveContactUseCase(
          harness.contacts,
          harness.logger,
        ).execute(ContactDraft.blank(), now: testNow),
        throwsA(isA<BlankContactException>()),
      );

      final record = recordOf('contact.save.rejected');
      expect(record.level, LogLevel.warn);
      expect(record.attributes['reason'], 'blank');
    });

    test('aucun nom, aucun numéro ne part dans le journal', () async {
      final draft = ContactDraft.blank()..first = 'Marie';
      draft.phones.first.value = '06 12 34 56 78';

      await SaveContactUseCase(harness.contacts, harness.logger).execute(draft, now: testNow);

      // Le carnet ne quitte pas l'appareil : le journal ne transporte que des
      // identifiants et des compteurs (cf. README, « Observabilité »).
      final written = harness.logs.records.map((r) => '${r.message} ${r.attributes}').join(' ');
      expect(written, isNot(contains('Marie')));
      expect(written, isNot(contains('06 12 34 56 78')));
    });

    test('les favoris disent combien de fiches ont bougé, et dans quel sens', () async {
      await harness.contacts.saveAll([aContact(first: 'Marie'), aContact(first: 'Paul')]);
      final ids = [for (final c in await harness.contacts.listAll()) c.id.value];

      await ToggleStarUseCase(harness.contacts, harness.logger).execute(ids, starred: true);

      final record = recordOf('contact.starred');
      expect(record.attributes['contacts.count'], 2);
      expect(record.attributes['contact.starred'], isTrue);
    });
  });

  group('Corbeille', () {
    test('mise à la corbeille, restauration et suppression définitive', () async {
      final contact = aContact(first: 'Marie');
      await harness.contacts.save(contact);
      final ids = [contact.id.value];

      await MoveToTrashUseCase(
        harness.contacts,
        harness.trash,
        harness.logger,
      ).execute(ids, now: testNow);
      expect(recordOf('contact.trashed').attributes['contacts.count'], 1);

      await RestoreFromTrashUseCase(
        harness.contacts,
        harness.trash,
        harness.logger,
      ).execute(ids, now: testNow);
      expect(recordOf('trash.restored').attributes['contacts.count'], 1);

      await MoveToTrashUseCase(
        harness.contacts,
        harness.trash,
        harness.logger,
      ).execute(ids, now: testNow);
      await DeleteForeverUseCase(harness.trash, harness.logger).execute(ids);
      expect(recordOf('trash.deleted_forever').attributes['contacts.count'], 1);
    });

    test('la purge automatique compte ce qu\'elle a effacé', () async {
      await harness.trash.put([
        aContact(first: 'Marie', deletedAt: testNow.subtract(const Duration(days: 40))),
      ]);

      await PurgeExpiredTrashUseCase(harness.trash, harness.logger).execute(now: testNow);

      expect(recordOf('trash.purged').attributes['contacts.count'], 1);
    });

    test('une corbeille sans expiration ne dit rien', () async {
      await harness.trash.put([aContact(first: 'Marie', deletedAt: testNow)]);

      await PurgeExpiredTrashUseCase(harness.trash, harness.logger).execute(now: testNow);

      expect(harness.logs.messages, isNot(contains('trash.purged')));
    });
  });

  group('Organiser', () {
    test('une fusion nomme la survivante et compte les absorbées', () async {
      await harness.contacts.saveAll([
        aContact(first: 'Marie', emails: ['marie@example.org']),
        aContact(first: 'Marie', emails: ['marie@example.org'], phones: ['0612345678']),
      ]);
      final ids = [for (final c in await harness.contacts.listAll()) c.id.value];

      final id = await MergeContactsUseCase(
        harness.contacts,
        harness.logger,
      ).execute(ids, now: testNow);

      final record = recordOf('contacts.merged');
      expect(record.attributes['contact.id'], id);
      expect(record.attributes['contacts.count'], 2);
    });

    test('une fusion sans matière à fusionner se signale sans échouer', () async {
      await MergeContactsUseCase(harness.contacts, harness.logger).execute(['inconnu']);

      final record = recordOf('contacts.merge.skipped');
      expect(record.level, LogLevel.warn);
      expect(record.attributes['contacts.found'], 0);
    });

    test('un import annonce fiches et étiquettes créées', () async {
      const vcf = '''
BEGIN:VCARD
VERSION:3.0
FN:Marie Dupont
N:Dupont;Marie;;;
CATEGORIES:Voisins
END:VCARD
''';

      await ImportVCardUseCase(
        harness.contacts,
        harness.labels,
        harness.logger,
      ).execute(vcf, now: testNow);

      final record = recordOf('vcard.imported');
      expect(record.attributes['contacts.count'], 1);
      expect(record.attributes['labels.created'], 1);
    });
  });

  group('Étiquettes', () {
    test('création, puis refus d\'un homonyme', () async {
      final create = CreateLabelUseCase(harness.labels, harness.logger);
      final id = await create.execute('Travail', now: testNow);
      expect(recordOf('label.created').attributes['label.id'], id);

      await expectLater(
        create.execute('travail', now: testNow),
        throwsA(isA<LabelAlreadyExistsException>()),
      );
      final rejected = recordOf('label.create.rejected');
      expect(rejected.level, LogLevel.warn);
      expect(rejected.attributes['reason'], 'duplicate');
    });

    test('la pose en lot dit combien de fiches et dans quel sens', () async {
      await harness.contacts.saveAll([aContact(first: 'Marie'), aContact(first: 'Paul')]);
      final ids = [for (final c in await harness.contacts.listAll()) c.id.value];
      final labelId = await CreateLabelUseCase(
        harness.labels,
        harness.logger,
      ).execute('Amis', now: testNow);

      await ApplyLabelUseCase(
        harness.contacts,
        harness.logger,
      ).execute(ids, labelId, apply: true, now: testNow);

      final record = recordOf('label.applied');
      expect(record.attributes['label.id'], labelId);
      expect(record.attributes['contacts.count'], 2);
      expect(record.attributes['label.applied'], isTrue);
    });
  });
}
