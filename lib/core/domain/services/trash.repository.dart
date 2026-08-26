import 'package:contacts/core/domain/model/contact.dart';

/// Port de la corbeille.
///
/// Le carnet d'adresses du système n'a pas de corbeille : une fiche supprimée
/// l'est définitivement. Pour offrir malgré tout les 30 jours de rétention de
/// Google Contacts, l'app **recopie** la fiche ici avant de la retirer du
/// carnet, et la réinsère à la restauration.
///
/// C'est donc le seul stockage propre à l'app — d'où une base locale, séparée
/// du carnet.
abstract interface class TrashRepository {
  Stream<int> get changes;

  /// Les fiches à la corbeille, `deletedAt` renseigné.
  Future<List<Contact>> listAll();

  Future<Contact?> getById(String id);

  Future<void> put(Iterable<Contact> contacts);

  Future<void> remove(Iterable<String> ids);
}
