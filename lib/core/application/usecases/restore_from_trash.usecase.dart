import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/core/domain/services/trash.repository.dart';

/// Remet des fiches de la corbeille dans le carnet du système.
///
/// La fiche y est **réinsérée** : le carnet lui attribue un nouvel
/// identifiant, l'ancien ayant disparu avec elle. Rien d'autre ne change.
class RestoreFromTrashUseCase {
  const RestoreFromTrashUseCase(this._contacts, this._trash, this._logger);

  final ContactRepository _contacts;
  final TrashRepository _trash;
  final LoggerApplicationService _logger;

  Future<void> execute(Iterable<String> ids, {DateTime? now}) async {
    final wanted = ids.toSet();
    if (wanted.isEmpty) return;

    final trashed = await _trash.listAll();
    final restored = [
      for (final c in trashed)
        if (wanted.contains(c.id.value))
          c.copyWith(clearDeletedAt: true, updatedAt: now ?? DateTime.now()),
    ];
    if (restored.isEmpty) {
      await _logger.warn('trash.restore.not_found', attrs: {'contacts.count': wanted.length});
      return;
    }

    try {
      await _contacts.saveAll(restored);
      // Le retrait de la corbeille vient après la réinsertion : si celle-ci
      // échoue, la fiche est toujours là et l'utilisateur peut réessayer.
      await _trash.remove([for (final c in restored) c.id.value]);
    } catch (e, st) {
      await _logger.error(
        'trash.restore.failed',
        attrs: {'contacts.count': restored.length},
        error: e,
        stack: st,
      );
      rethrow;
    }
    await _logger.info('trash.restored', attrs: {'contacts.count': restored.length});
  }
}
