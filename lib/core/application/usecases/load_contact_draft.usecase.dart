import 'package:contacts/core/application/dtos/contact_draft.dto.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';

/// Prépare le formulaire d'édition : le brouillon d'une fiche existante, ou un
/// formulaire vierge pour une création.
class LoadContactDraftUseCase {
  const LoadContactDraftUseCase(this._contacts);

  final ContactRepository _contacts;

  Future<ContactDraft> execute({String? contactId, Set<String> labelIds = const {}}) async {
    if (contactId == null) return ContactDraft.blank(labelIds: labelIds);
    final contact = await _contacts.getById(contactId);
    if (contact == null) return ContactDraft.blank(labelIds: labelIds);
    return ContactDraft.fromDomain(contact);
  }
}
