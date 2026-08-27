import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/core/domain/services/trash.repository.dart';

/// Envoie des fiches à la corbeille.
///
/// Le carnet du système ne connaît pas la suppression logique : la fiche est
/// **recopiée** dans la corbeille de l'app, puis retirée du carnet. Elle
/// disparaît donc aussitôt des autres applications, comme le veut une
/// suppression — mais reste restaurable ici pendant 30 jours.
class MoveToTrashUseCase {
  const MoveToTrashUseCase(this._contacts, this._trash, this._logger);

  final ContactRepository _contacts;
  final TrashRepository _trash;
  final LoggerApplicationService _logger;

  Future<void> execute(Iterable<String> ids, {DateTime? now}) async {
    final at = now ?? DateTime.now();
    final wanted = ids.toSet();
    if (wanted.isEmpty) return;

    final all = await _contacts.listAll();
    final doomed = [
      for (final c in all)
        if (wanted.contains(c.id.value)) c.copyWith(deletedAt: at, updatedAt: at),
    ];
    if (doomed.isEmpty) {
      await _logger.warn('contact.trash.not_found', attrs: {'contacts.count': wanted.length});
      return;
    }

    // La copie d'abord : si le retrait du carnet échoue, la fiche existe
    // encore aux deux endroits, ce qui se rattrape. L'inverse la perdrait.
    try {
      await _trash.put(doomed);
    } catch (e, st) {
      await _logger.error(
        'contact.trash.failed',
        attrs: {'contacts.count': doomed.length, 'step': 'copy'},
        error: e,
        stack: st,
      );
      rethrow;
    }

    try {
      await _contacts.delete([for (final c in doomed) c.id.value]);
    } catch (e, st) {
      // L'état à moitié fait mérite son propre message : la fiche est à la fois
      // dans le carnet et dans la corbeille, elle va donc réapparaître en double
      // à l'écran. Sans cette ligne, le doublon reste inexplicable.
      await _logger.error(
        'contact.trash.failed',
        attrs: {'contacts.count': doomed.length, 'step': 'delete'},
        error: e,
        stack: st,
      );
      rethrow;
    }

    await _logger.info('contact.trashed', attrs: {'contacts.count': doomed.length});
  }
}
