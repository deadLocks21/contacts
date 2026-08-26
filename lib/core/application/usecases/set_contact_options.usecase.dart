import 'package:contacts/core/domain/services/contact.repository.dart';

/// Réglages propres à une fiche, dans le menu « ⋮ » : sonnerie personnalisée
/// et renvoi direct vers la messagerie vocale.
class SetContactOptionsUseCase {
  const SetContactOptionsUseCase(this._contacts);

  final ContactRepository _contacts;

  Future<void> execute(
    String id, {
    String? customRingtone,
    bool clearRingtone = false,
    bool? sendToVoicemail,
    DateTime? now,
  }) async {
    final contact = await _contacts.getById(id);
    if (contact == null) return;
    await _contacts.save(
      contact.copyWith(
        customRingtone: customRingtone,
        clearRingtone: clearRingtone,
        sendToVoicemail: sendToVoicemail ?? contact.sendToVoicemail,
        updatedAt: now ?? DateTime.now(),
      ),
    );
  }
}
