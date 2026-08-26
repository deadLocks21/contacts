import 'dart:io';

import 'package:contacts/core/domain/services/photo.store.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Photos de contact recopiées dans `<documents>/contact_photos/`.
///
/// Le nom du fichier porte l'horodatage : remplacer la photo d'un contact
/// écrit un nouveau fichier plutôt que d'écraser l'ancien, ce qui évite que
/// le cache d'images de Flutter continue d'afficher la précédente.
class LocalFilePhotoStore implements PhotoStore {
  static const _folder = 'contact_photos';

  @override
  Future<String> persist(String sourcePath, String contactId) async {
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(documents.path, _folder));
    if (!directory.existsSync()) await directory.create(recursive: true);

    final extension = p.extension(sourcePath).isEmpty ? '.jpg' : p.extension(sourcePath);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final target = p.join(directory.path, '$contactId-$stamp$extension');
    await File(sourcePath).copy(target);
    return target;
  }

  @override
  Future<void> remove(String path) async {
    final file = File(path);
    if (file.existsSync()) await file.delete();
  }
}

/// Store de photos sans effet — web et tests, où il n'y a pas de système de
/// fichiers à alimenter : le chemin source est conservé tel quel.
class InMemoryPhotoStore implements PhotoStore {
  final removed = <String>[];

  @override
  Future<String> persist(String sourcePath, String contactId) async => sourcePath;

  @override
  Future<void> remove(String path) async => removed.add(path);
}
