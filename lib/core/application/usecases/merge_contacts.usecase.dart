import 'package:contacts/core/application/services/contact_merge.service.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';

/// Fusionne des fiches en une seule : la plus ancienne survit, enrichie de tout
/// ce que portaient les autres, qui sont ensuite supprimées définitivement
/// (elles n'ont plus rien d'unique à conserver).
class MergeContactsUseCase {
  const MergeContactsUseCase(this._contacts);

  final ContactRepository _contacts;

  /// Renvoie l'identifiant de la fiche fusionnée.
  Future<String> execute(Iterable<String> ids, {DateTime? now}) async {
    final wanted = ids.toSet();
    final all = await _contacts.listAll();
    final members = [
      for (final c in all)
        if (wanted.contains(c.id.value)) c,
    ];
    if (members.length < 2) {
      return members.isEmpty ? '' : members.first.id.value;
    }

    final merged = ContactMerge.merge(members, now: now);
    final absorbed = ContactMerge.absorbedIds(members).map((id) => id.value);
    await _contacts.save(merged);
    await _contacts.purge(absorbed);
    return merged.id.value;
  }
}
