import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/core/domain/services/photo.store.dart';

/// Supprime définitivement des fiches, et les photos qu'elles étaient seules
/// à utiliser — sans quoi l'espace de l'app se remplirait d'orphelines.
class DeleteForeverUseCase {
  const DeleteForeverUseCase(this._contacts, this._photos);

  final ContactRepository _contacts;
  final PhotoStore _photos;

  Future<void> execute(Iterable<String> ids) async {
    final wanted = ids.toSet();
    if (wanted.isEmpty) return;
    final all = await _contacts.listAll(includeTrashed: true);

    final doomedPhotos = <String>{
      for (final c in all)
        if (wanted.contains(c.id.value) && c.photoPath != null) c.photoPath!,
    };
    final keptPhotos = <String>{
      for (final c in all)
        if (!wanted.contains(c.id.value) && c.photoPath != null) c.photoPath!,
    };

    await _contacts.purge(wanted);
    for (final path in doomedPhotos.difference(keptPhotos)) {
      await _photos.remove(path);
    }
  }
}
