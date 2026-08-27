import 'dart:async';

import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/core/domain/services/contacts_access.service.dart';
import 'package:contacts/core/domain/services/label.repository.dart';
import 'package:contacts/core/domain/services/trash.repository.dart';
import 'package:contacts/infrastructure/contacts/flutter_contacts.contact.repository.dart';
import 'package:contacts/infrastructure/contacts/flutter_contacts.contacts_access.service.dart';
import 'package:contacts/infrastructure/contacts/local.contact.repository.dart';
import 'package:contacts/infrastructure/labels/flutter_contacts.label.repository.dart';
import 'package:contacts/infrastructure/labels/local.label.repository.dart';
import 'package:contacts/infrastructure/providers/infra_providers.dart';
import 'package:contacts/infrastructure/providers/logger.service_provider.dart';
import 'package:contacts/infrastructure/trash/local.trash.repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repository_providers.g.dart';

/// Assemblage des ports : carnet du système sur mobile, doublures locales
/// partout ailleurs. C'est le seul endroit qui connaît les deux.

@Riverpod(keepAlive: true)
ContactRepository contactRepository(Ref ref) {
  if (ref.watch(useDeviceContactsProvider)) {
    final repository = FlutterContactsContactRepository(ref.watch(loggerProvider));
    ref.onDispose(repository.dispose);
    return repository;
  }
  return LocalContactRepository(ref.watch(localRecordStoreProvider));
}

@Riverpod(keepAlive: true)
LabelRepository labelRepository(Ref ref) {
  if (ref.watch(useDeviceContactsProvider)) {
    final repository = FlutterContactsLabelRepository(ref.watch(loggerProvider));
    ref.onDispose(repository.dispose);
    return repository;
  }
  return LocalLabelRepository(ref.watch(localRecordStoreProvider));
}

@Riverpod(keepAlive: true)
ContactsAccess contactsAccess(Ref ref) => ref.watch(useDeviceContactsProvider)
    ? const FlutterContactsAccess()
    : const AlwaysGrantedContactsAccess();

/// Autorisation de lire le carnet, demandée au démarrage. `false` = l'écran
/// d'accueil propose d'ouvrir l'accès au lieu d'annoncer un carnet vide.
@Riverpod(keepAlive: true)
class ContactsPermission extends _$ContactsPermission {
  @override
  Future<bool> build() => ref.watch(contactsAccessProvider).request();

  /// Redemande l'accès — le bouton « Autoriser » de l'écran d'accueil.
  Future<void> retry() async {
    state = const AsyncLoading();
    final granted = await ref.read(contactsAccessProvider).request();
    // Un second refus se distingue du premier : c'est le signe que l'accès a
    // été coupé dans les réglages du système, où l'app ne peut plus rien.
    await ref.read(loggerProvider).info('contacts.permission.retried', attrs: {'granted': granted});
    state = AsyncData(granted);
  }
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
