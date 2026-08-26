import 'package:contacts/core/domain/model/contact_label.dart';

/// Port d'accès aux étiquettes.
abstract interface class LabelRepository {
  Stream<int> get changes;

  Future<List<ContactLabel>> listAll();

  Future<ContactLabel?> getById(String id);

  Future<void> save(ContactLabel label);

  /// Supprime l'étiquette. Les contacts qui la portaient ne sont pas supprimés :
  /// c'est au cas d'usage de retirer la référence de chaque fiche.
  Future<void> delete(String id);
}
