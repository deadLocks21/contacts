import 'package:contacts/core/domain/services/photo.store.dart';

/// Recopie dans l'espace de l'app la photo choisie par l'utilisateur et
/// renvoie le chemin à poser sur le brouillon.
///
/// Le fichier rendu par la galerie ou l'appareil photo vit dans un cache que
/// le système peut vider : le référencer tel quel ferait disparaître l'avatar
/// sans prévenir.
class SetContactPhotoUseCase {
  const SetContactPhotoUseCase(this._photos);

  final PhotoStore _photos;

  Future<String> execute(String sourcePath, {required String contactId}) =>
      _photos.persist(sourcePath, contactId);
}
