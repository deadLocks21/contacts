import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';

/// Réglages propres à une fiche, dans le menu « ⋮ » : sonnerie personnalisée
/// et renvoi direct vers la messagerie vocale.
class SetContactOptionsUseCase {
  const SetContactOptionsUseCase(this._contacts, this._logger);

  final ContactRepository _contacts;
  final LoggerApplicationService _logger;

  Future<void> execute(
    String id, {
    String? customRingtone,
    bool clearRingtone = false,
    bool? sendToVoicemail,
    DateTime? now,
  }) async {
    final contact = await _contacts.getById(id);
    if (contact == null) {
      await _logger.warn('contact.options.not_found', attrs: {'contact.id': id});
      return;
    }
    await _contacts.save(
      contact.copyWith(
        customRingtone: customRingtone,
        clearRingtone: clearRingtone,
        sendToVoicemail: sendToVoicemail ?? contact.sendToVoicemail,
        updatedAt: now ?? DateTime.now(),
      ),
    );
    await _logger.info(
      'contact.options.updated',
      attrs: {
        'contact.id': id,
        'contact.ringtone_cleared': clearRingtone,
        'contact.send_to_voicemail': ?sendToVoicemail,
      },
    );
  }
}
