import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/core/domain/services/label.repository.dart';
import 'package:contacts/infrastructure/contacts/local.contact.repository.dart';
import 'package:contacts/infrastructure/labels/local.label.repository.dart';
import 'package:contacts/infrastructure/persistence/local_record_store.dart';
import 'package:contacts/infrastructure/photos/local_file.photo.store.dart';

/// Pile complète montée en mémoire — les doublures sont les implémentations
/// `InMemory*` de l'app, pas des mocks : les tests passent donc par le vrai
/// code de persistance (codecs JSON compris).
class Harness {
  Harness() {
    store = InMemoryLocalRecordStore();
    contacts = LocalContactRepository(store);
    labels = LocalLabelRepository(store);
    photos = InMemoryPhotoStore();
  }

  late final InMemoryLocalRecordStore store;
  late final ContactRepository contacts;
  late final LabelRepository labels;
  late final InMemoryPhotoStore photos;
}
