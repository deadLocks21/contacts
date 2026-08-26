import 'package:contacts/core/domain/services/contact.repository.dart';

/// Ajoute ou retire des fiches des favoris.
///
/// En sélection multiple, Google applique le même état à tout le lot plutôt
/// que d'inverser chaque fiche : [starred] impose la valeur voulue.
class ToggleStarUseCase {
  const ToggleStarUseCase(this._contacts);

  final ContactRepository _contacts;

  Future<void> execute(Iterable<String> ids, {required bool starred, DateTime? now}) async {
    final wanted = ids.toSet();
    final all = await _contacts.listAll();
    final touched = [
      for (final c in all)
        if (wanted.contains(c.id.value) && c.starred != starred)
          c.copyWith(starred: starred, updatedAt: now ?? DateTime.now()),
    ];
    if (touched.isEmpty) return;
    await _contacts.saveAll(touched);
  }
}
