import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/core/domain/services/trash.repository.dart';

/// Remet des fiches de la corbeille dans le carnet du système.
///
/// La fiche y est **réinsérée** : le carnet lui attribue un nouvel
/// identifiant, l'ancien ayant disparu avec elle. Rien d'autre ne change.
class RestoreFromTrashUseCase {
  const RestoreFromTrashUseCase(this._contacts, this._trash);

  final ContactRepository _contacts;
  final TrashRepository _trash;

  Future<void> execute(Iterable<String> ids, {DateTime? now}) async {
    final wanted = ids.toSet();
    if (wanted.isEmpty) return;

    final trashed = await _trash.listAll();
    final restored = [
      for (final c in trashed)
        if (wanted.contains(c.id.value))
          c.copyWith(clearDeletedAt: true, updatedAt: now ?? DateTime.now()),
    ];
    if (restored.isEmpty) return;

    await _contacts.saveAll(restored);
    await _trash.remove([for (final c in restored) c.id.value]);
  }
}
