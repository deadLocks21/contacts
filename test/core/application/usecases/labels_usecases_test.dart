import 'package:contacts/core/application/usecases/apply_label.usecase.dart';
import 'package:contacts/core/application/usecases/create_label.usecase.dart';
import 'package:contacts/core/application/usecases/delete_label.usecase.dart';
import 'package:contacts/core/application/usecases/list_labels.usecase.dart';
import 'package:contacts/core/application/usecases/rename_label.usecase.dart';
import 'package:contacts/core/domain/exceptions/contact_exception.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures.dart';
import '../../../support/harness.dart';

void main() {
  late Harness harness;

  setUp(() => harness = Harness());

  test('crée une étiquette et la retrouve triée alphabétiquement', () async {
    final create = CreateLabelUseCase(harness.labels);
    await create.execute('Travail', now: testNow);
    await create.execute('Amis', now: testNow);

    final labels = await ListLabelsUseCase(harness.labels, harness.contacts).execute();

    expect([for (final l in labels) l.name], ['Amis', 'Travail']);
  });

  test('refuse un nom déjà pris, accents et casse ignorés', () async {
    final create = CreateLabelUseCase(harness.labels);
    await create.execute('Élèves', now: testNow);

    expect(() => create.execute('eleves', now: testNow),
        throwsA(isA<LabelAlreadyExistsException>()));
  });

  test('compte les contacts de chaque étiquette', () async {
    final id = await CreateLabelUseCase(harness.labels).execute('Travail', now: testNow);
    final contact = aContact(first: 'Marie');
    await harness.contacts.save(contact);
    await ApplyLabelUseCase(harness.contacts)
        .execute([contact.id.value], id, apply: true, now: testNow);

    final labels = await ListLabelsUseCase(harness.labels, harness.contacts).execute();

    expect(labels.single.contactCount, 1);
  });

  test('retirer une étiquette d\'une fiche ne supprime pas la fiche', () async {
    final id = await CreateLabelUseCase(harness.labels).execute('Travail', now: testNow);
    final contact = aContact(first: 'Marie');
    await harness.contacts.save(contact);
    final apply = ApplyLabelUseCase(harness.contacts);
    await apply.execute([contact.id.value], id, apply: true, now: testNow);

    await apply.execute([contact.id.value], id, apply: false, now: testNow);

    expect((await harness.contacts.getById(contact.id.value))!.labelIds, isEmpty);
  });

  test('renommer refuse de créer un homonyme', () async {
    final create = CreateLabelUseCase(harness.labels);
    final id = await create.execute('Travail', now: testNow);
    await create.execute('Amis', now: testNow);

    expect(() => RenameLabelUseCase(harness.labels).execute(id, 'amis', now: testNow),
        throwsA(isA<LabelAlreadyExistsException>()));
  });

  test('supprimer une étiquette conserve les contacts et retire la référence', () async {
    final id = await CreateLabelUseCase(harness.labels).execute('Travail', now: testNow);
    final contact = aContact(first: 'Marie');
    await harness.contacts.save(contact);
    await ApplyLabelUseCase(harness.contacts)
        .execute([contact.id.value], id, apply: true, now: testNow);

    await DeleteLabelUseCase(harness.labels, harness.contacts).execute(id, now: testNow);

    expect(await harness.labels.listAll(), isEmpty);
    final kept = await harness.contacts.getById(contact.id.value);
    expect(kept, isNotNull);
    expect(kept!.labelIds, isEmpty);
  });
}
