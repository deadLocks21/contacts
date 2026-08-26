import 'package:contacts/core/domain/services/trash.repository.dart';

/// Vide définitivement des fiches de la corbeille.
///
/// La fiche a déjà quitté le carnet du système au moment de sa mise à la
/// corbeille : il ne reste que la copie locale à effacer.
class DeleteForeverUseCase {
  const DeleteForeverUseCase(this._trash);

  final TrashRepository _trash;

  Future<void> execute(Iterable<String> ids) async {
    if (ids.isEmpty) return;
    await _trash.remove(ids);
  }
}
