import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:contacts/core/domain/services/trash.repository.dart';

/// Vide de la corbeille ce qui y séjourne depuis plus de 30 jours.
///
/// Appelé au démarrage : c'est le seul moment où l'app peut constater
/// l'expiration, faute de tâche de fond.
class PurgeExpiredTrashUseCase {
  const PurgeExpiredTrashUseCase(this._trash, this._logger);

  final TrashRepository _trash;
  final LoggerApplicationService _logger;

  /// Renvoie le nombre de fiches purgées.
  Future<int> execute({DateTime? now}) async {
    final at = now ?? DateTime.now();
    final expired = [
      for (final c in await _trash.listAll())
        if (c.purgeAt != null && !c.purgeAt!.isAfter(at)) c.id.value,
    ];
    if (expired.isEmpty) return 0;
    await _trash.remove(expired);
    // Une purge est silencieuse par nature — l'utilisateur ne voit que des
    // fiches qui ont disparu. La trace dit combien, et quand.
    await _logger.info('trash.purged', attrs: {'contacts.count': expired.length});
    return expired.length;
  }
}
