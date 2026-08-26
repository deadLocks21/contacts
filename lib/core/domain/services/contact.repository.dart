import 'package:contacts/core/domain/model/contact.dart';

/// Port d'accès aux contacts. Le store local est la source de vérité :
/// toutes les lectures viennent de lui.
///
/// La suppression logique (corbeille) n'est **pas** une opération du port :
/// c'est un `deletedAt` posé par le cas d'usage puis un [save] ordinaire.
/// [purge] est la seule suppression réelle.
abstract interface class ContactRepository {
  /// Émet un numéro de révision monotone à chaque écriture — l'UI s'y abonne
  /// pour se rafraîchir (un compteur, pas un booléen, pour que Riverpod
  /// renotifie à *chaque* changement et pas seulement au premier).
  Stream<int> get changes;

  /// Tous les contacts ; ceux à la corbeille sont exclus sauf demande contraire.
  Future<List<Contact>> listAll({bool includeTrashed = false});

  /// Les contacts à la corbeille, uniquement.
  Future<List<Contact>> listTrashed();

  Future<Contact?> getById(String id);

  /// Upsert.
  Future<void> save(Contact contact);

  /// Upsert en lot — une seule notification de changement.
  Future<void> saveAll(Iterable<Contact> contacts);

  /// Suppression définitive (vidage de la corbeille, purge des 30 jours).
  Future<void> purge(Iterable<String> ids);
}
