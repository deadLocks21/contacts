import 'package:contacts/core/application/dtos/contact_draft.dto.dart';
import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:contacts/core/domain/exceptions/contact_exception.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';

/// Enregistre le formulaire d'édition, en création comme en modification.
///
/// Refuse une fiche entièrement vide : Google Contacts grise son bouton
/// « Enregistrer » dans ce cas, on lève ici l'exception que l'UI traduit.
class SaveContactUseCase {
  const SaveContactUseCase(this._contacts, this._logger);

  final ContactRepository _contacts;
  final LoggerApplicationService _logger;

  /// Renvoie l'identifiant de la fiche enregistrée.
  Future<String> execute(ContactDraft draft, {DateTime? now}) async {
    final creating = draft.id == null;
    try {
      final base = draft.id == null ? null : await _contacts.getById(draft.id!);
      final contact = draft.toDomain(base: base, now: now);
      if (contact.isBlank) {
        await _logger.warn('contact.save.rejected', attrs: {'reason': 'blank'});
        throw const BlankContactException();
      }
      // C'est le carnet qui alloue l'identifiant d'une fiche neuve : on rend le
      // sien, pas celui du brouillon.
      final id = await _contacts.save(contact);
      await _logger.info('contact.saved', attrs: {'contact.id': id, 'contact.created': creating});
      return id;
    } on BlankContactException {
      rethrow;
    } catch (e, st) {
      // Une écriture refusée par le carnet du système (permission retirée entre
      // deux écrans, fiche appartenant à un compte en lecture seule) ne se voit
      // sinon nulle part : l'UI ne montre que l'échec, jamais sa cause.
      await _logger.error(
        'contact.save.failed',
        attrs: {'contact.id': ?draft.id, 'contact.created': creating},
        error: e,
        stack: st,
      );
      rethrow;
    }
  }
}
