import 'package:contacts/core/application/dtos/contact_draft.dto.dart';
import 'package:contacts/core/domain/exceptions/contact_exception.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';

/// Enregistre le formulaire d'édition, en création comme en modification.
///
/// Refuse une fiche entièrement vide : Google Contacts grise son bouton
/// « Enregistrer » dans ce cas, on lève ici l'exception que l'UI traduit.
class SaveContactUseCase {
  const SaveContactUseCase(this._contacts);

  final ContactRepository _contacts;

  /// Renvoie l'identifiant de la fiche enregistrée.
  Future<String> execute(ContactDraft draft, {DateTime? now}) async {
    final base = draft.id == null ? null : await _contacts.getById(draft.id!);
    final contact = draft.toDomain(base: base, now: now);
    if (contact.isBlank) throw const BlankContactException();
    // C'est le carnet qui alloue l'identifiant d'une fiche neuve : on rend le
    // sien, pas celui du brouillon.
    return _contacts.save(contact);
  }
}
