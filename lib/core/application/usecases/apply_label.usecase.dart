import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:contacts/core/domain/model/entity_id.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';

/// Pose ou retire une étiquette sur un lot de fiches (sélection multiple, ou
/// menu « Modifier les étiquettes » d'une fiche).
class ApplyLabelUseCase {
  const ApplyLabelUseCase(this._contacts, this._logger);

  final ContactRepository _contacts;
  final LoggerApplicationService _logger;

  Future<void> execute(
    Iterable<String> contactIds,
    String labelId, {
    required bool apply,
    DateTime? now,
  }) async {
    final wanted = contactIds.toSet();
    final label = EntityId(labelId);
    final all = await _contacts.listAll();

    final updates = [
      for (final c in all)
        if (wanted.contains(c.id.value) && c.labelIds.contains(label) != apply)
          c.copyWith(
            labelIds: apply ? {...c.labelIds, label} : ({...c.labelIds}..remove(label)),
            updatedAt: now ?? DateTime.now(),
          ),
    ];
    if (updates.isEmpty) return;
    try {
      await _contacts.saveAll(updates);
    } catch (e, st) {
      // Écriture en lot : un échec à mi-parcours laisse une partie de la
      // sélection étiquetée et l'autre non, sans que rien ne le signale.
      await _logger.error(
        'label.apply.failed',
        attrs: {'label.id': labelId, 'contacts.count': updates.length, 'label.applied': apply},
        error: e,
        stack: st,
      );
      rethrow;
    }
    await _logger.info(
      'label.applied',
      attrs: {'label.id': labelId, 'contacts.count': updates.length, 'label.applied': apply},
    );
  }
}
