import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/core/domain/services/label.repository.dart';
import 'package:contacts/core/domain/services/trash.repository.dart';
import 'package:contacts/infrastructure/contacts/local.contact.repository.dart';
import 'package:contacts/infrastructure/labels/local.label.repository.dart';
import 'package:contacts/infrastructure/persistence/local_record_store.dart';
import 'package:contacts/infrastructure/trash/local.trash.repository.dart';

/// Pile complète montée en mémoire — les doublures sont les implémentations
/// locales de l'app, celles qui tiennent lieu de carnet système hors mobile.
/// Les tests passent donc par le vrai code de persistance, codecs compris.
class Harness {
  Harness() {
    store = InMemoryLocalRecordStore();
    contacts = LocalContactRepository(store);
    labels = LocalLabelRepository(store);
    trash = LocalTrashRepository(store);
  }

  late final InMemoryLocalRecordStore store;
  late final ContactRepository contacts;
  late final LabelRepository labels;
  late final TrashRepository trash;
}
