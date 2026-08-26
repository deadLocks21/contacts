import 'package:contacts/core/domain/services/contact.repository.dart';

/// Sort des fiches de la corbeille et les remet dans le carnet.
class RestoreFromTrashUseCase {
  const RestoreFromTrashUseCase(this._contacts);

  final ContactRepository _contacts;

  Future<void> execute(Iterable<String> ids, {DateTime? now}) async {
    final wanted = ids.toSet();
    final trashed = await _contacts.listTrashed();
    final touched = [
      for (final c in trashed)
        if (wanted.contains(c.id.value))
          c.copyWith(clearDeletedAt: true, updatedAt: now ?? DateTime.now()),
    ];
    if (touched.isEmpty) return;
    await _contacts.saveAll(touched);
  }
}
