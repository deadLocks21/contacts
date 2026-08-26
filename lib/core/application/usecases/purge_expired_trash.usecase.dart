import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/core/domain/services/photo.store.dart';
import 'package:contacts/core/application/usecases/delete_forever.usecase.dart';

/// Vide de la corbeille ce qui y séjourne depuis plus de 30 jours.
/// Appelé au démarrage : c'est le seul moment où l'app peut constater
/// l'expiration, faute de tâche de fond.
class PurgeExpiredTrashUseCase {
  PurgeExpiredTrashUseCase(this._contacts, PhotoStore photos)
    : _deleteForever = DeleteForeverUseCase(_contacts, photos);

  final ContactRepository _contacts;
  final DeleteForeverUseCase _deleteForever;

  /// Renvoie le nombre de fiches purgées.
  Future<int> execute({DateTime? now}) async {
    final at = now ?? DateTime.now();
    final expired = [
      for (final c in await _contacts.listTrashed())
        if (c.purgeAt != null && !c.purgeAt!.isAfter(at)) c.id.value,
    ];
    if (expired.isEmpty) return 0;
    await _deleteForever.execute(expired);
    return expired.length;
  }
}
