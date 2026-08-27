import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:contacts/core/domain/services/trash.repository.dart';

/// Vide définitivement des fiches de la corbeille.
///
/// La fiche a déjà quitté le carnet du système au moment de sa mise à la
/// corbeille : il ne reste que la copie locale à effacer.
class DeleteForeverUseCase {
  const DeleteForeverUseCase(this._trash, this._logger);

  final TrashRepository _trash;
  final LoggerApplicationService _logger;

  Future<void> execute(Iterable<String> ids) async {
    final wanted = ids.toList();
    if (wanted.isEmpty) return;
    await _trash.remove(wanted);
    // Une suppression irréversible se journalise : c'est la seule opération de
    // l'app dont on ne peut rien reconstituer après coup.
    await _logger.info('trash.deleted_forever', attrs: {'contacts.count': wanted.length});
  }
}
