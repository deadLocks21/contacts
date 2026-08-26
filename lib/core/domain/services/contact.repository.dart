import 'package:contacts/core/domain/model/contact.dart';

/// Port d'accès au **carnet d'adresses**.
///
/// L'implémentation réelle s'adosse au carnet du système (`ContactsContract`
/// sur Android, `Contacts` sur iOS) : c'est lui la source de vérité, partagée
/// avec le composeur, la messagerie et toutes les autres apps de l'appareil.
/// L'app ne tient donc pas sa propre base de contacts.
///
/// La corbeille n'est pas de son ressort : le carnet du système n'en a pas
/// (cf. [TrashRepository]). Ici, supprimer supprime.
abstract interface class ContactRepository {
  /// Émet un numéro de révision monotone à chaque écriture — l'UI s'y abonne
  /// pour se rafraîchir, y compris quand le carnet change depuis une **autre**
  /// application.
  Stream<int> get changes;

  /// Rend une liste vide si la permission n'est pas accordée : ce n'est pas une
  /// erreur, l'UI propose alors d'ouvrir l'accès.
  Future<List<Contact>> listAll();

  Future<Contact?> getById(String id);

  /// Insère ou met à jour. Rend l'identifiant **retenu par le carnet**, qui
  /// n'est pas celui de la fiche à l'insertion : c'est le système qui l'alloue.
  Future<String> save(Contact contact);

  Future<void> saveAll(Iterable<Contact> contacts);

  /// Suppression réelle. Les cas d'usage passent d'abord par la corbeille.
  Future<void> delete(Iterable<String> ids);
}
