import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/core/domain/services/trash.repository.dart';

/// Envoie des fiches à la corbeille.
///
/// Le carnet du système ne connaît pas la suppression logique : la fiche est
/// **recopiée** dans la corbeille de l'app, puis retirée du carnet. Elle
/// disparaît donc aussitôt des autres applications, comme le veut une
/// suppression — mais reste restaurable ici pendant 30 jours.
class MoveToTrashUseCase {
  const MoveToTrashUseCase(this._contacts, this._trash);

  final ContactRepository _contacts;
  final TrashRepository _trash;

  Future<void> execute(Iterable<String> ids, {DateTime? now}) async {
    final at = now ?? DateTime.now();
    final wanted = ids.toSet();
    if (wanted.isEmpty) return;

    final all = await _contacts.listAll();
    final doomed = [
      for (final c in all)
        if (wanted.contains(c.id.value)) c.copyWith(deletedAt: at, updatedAt: at),
    ];
    if (doomed.isEmpty) return;

    // La copie d'abord : si le retrait du carnet échoue, la fiche existe
    // encore aux deux endroits, ce qui se rattrape. L'inverse la perdrait.
    await _trash.put(doomed);
    await _contacts.delete([for (final c in doomed) c.id.value]);
  }
}
