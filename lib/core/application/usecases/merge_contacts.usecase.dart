import 'package:contacts/core/application/services/contact_merge.service.dart';
import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';

/// Fusionne des fiches en une seule : la plus ancienne survit, enrichie de tout
/// ce que portaient les autres, qui sont ensuite supprimées définitivement
/// (elles n'ont plus rien d'unique à conserver).
class MergeContactsUseCase {
  const MergeContactsUseCase(this._contacts, this._logger);

  final ContactRepository _contacts;
  final LoggerApplicationService _logger;

  /// Renvoie l'identifiant de la fiche fusionnée.
  Future<String> execute(Iterable<String> ids, {DateTime? now}) async {
    final wanted = ids.toSet();
    final all = await _contacts.listAll();
    final members = [
      for (final c in all)
        if (wanted.contains(c.id.value)) c,
    ];
    if (members.length < 2) {
      await _logger.warn(
        'contacts.merge.skipped',
        attrs: {'contacts.requested': wanted.length, 'contacts.found': members.length},
      );
      return members.isEmpty ? '' : members.first.id.value;
    }

    final merged = ContactMerge.merge(members, now: now);
    final absorbed = ContactMerge.absorbedIds(members).map((id) => id.value);
    try {
      final id = await _contacts.save(merged);
      await _contacts.delete(absorbed);
      await _logger.info(
        'contacts.merged',
        attrs: {'contact.id': id, 'contacts.count': members.length},
      );
      return id;
    } catch (e, st) {
      // La fusion écrit puis supprime : un échec entre les deux laisse la fiche
      // fusionnée **et** ses sources dans le carnet, donc de nouveaux doublons.
      await _logger.error(
        'contacts.merge.failed',
        attrs: {'contacts.count': members.length},
        error: e,
        stack: st,
      );
      rethrow;
    }
  }
}
