import 'dart:async';

import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/core/domain/services/label.repository.dart';
import 'package:contacts/core/domain/services/trash.repository.dart';
import 'package:contacts/infrastructure/contacts/flutter_contacts.contact.repository.dart';
import 'package:contacts/infrastructure/contacts/local.contact.repository.dart';
import 'package:contacts/infrastructure/labels/flutter_contacts.label.repository.dart';
import 'package:contacts/infrastructure/labels/local.label.repository.dart';
import 'package:contacts/infrastructure/providers/infra_providers.dart';
import 'package:contacts/infrastructure/trash/local.trash.repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repository_providers.g.dart';

/// Assemblage des ports : carnet du système sur mobile, doublures locales
/// partout ailleurs. C'est le seul endroit qui connaît les deux.

@Riverpod(keepAlive: true)
ContactRepository contactRepository(Ref ref) {
  if (ref.watch(useDeviceContactsProvider)) {
    final repository = FlutterContactsContactRepository();
    ref.onDispose(repository.dispose);
    return repository;
  }
  return LocalContactRepository(ref.watch(localRecordStoreProvider));
}

@Riverpod(keepAlive: true)
LabelRepository labelRepository(Ref ref) {
  if (ref.watch(useDeviceContactsProvider)) {
    final repository = FlutterContactsLabelRepository();
    ref.onDispose(repository.dispose);
    return repository;
  }
  return LocalLabelRepository(ref.watch(localRecordStoreProvider));
}

/// La corbeille est toujours locale : le carnet du système n'en a pas.
@Riverpod(keepAlive: true)
TrashRepository trashRepository(Ref ref) =>
    LocalTrashRepository(ref.watch(localRecordStoreProvider));

/// Émet à chaque écriture, d'où qu'elle vienne — carnet du système (y compris
/// modifié par une autre app) comme corbeille. Les vues du carnet s'y abonnent
/// pour se recalculer.
@riverpod
Stream<int> storeChanges(Ref ref) {
  final contacts = ref.watch(contactRepositoryProvider).changes;
  final labels = ref.watch(labelRepositoryProvider).changes;
  final trash = ref.watch(trashRepositoryProvider).changes;

  final controller = StreamController<int>.broadcast();
  var revision = 0;
  final subscriptions = [
    for (final source in [contacts, labels, trash])
      source.listen((_) => controller.add(++revision)),
  ];
  ref.onDispose(() {
    for (final s in subscriptions) {
      s.cancel();
    }
    controller.close();
  });
  return controller.stream;
}
