import 'package:contacts/core/domain/services/contact.repository.dart';

/// Envoie des fiches à la corbeille — suppression **logique**, réversible
/// pendant 30 jours (cf. `Contact.trashRetention`).
class MoveToTrashUseCase {
  const MoveToTrashUseCase(this._contacts);

  final ContactRepository _contacts;

  Future<void> execute(Iterable<String> ids, {DateTime? now}) async {
    final at = now ?? DateTime.now();
    final wanted = ids.toSet();
    final all = await _contacts.listAll();
    final touched = [
      for (final c in all)
        if (wanted.contains(c.id.value)) c.copyWith(deletedAt: at, updatedAt: at),
    ];
    if (touched.isEmpty) return;
    await _contacts.saveAll(touched);
  }
}
