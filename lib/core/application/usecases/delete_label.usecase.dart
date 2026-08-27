import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/core/domain/services/label.repository.dart';

/// Supprime une étiquette. Les fiches qui la portaient sont **conservées** —
/// on ne fait que leur retirer la référence, comme Google Contacts qui prévient
/// « Les contacts ne seront pas supprimés ».
class DeleteLabelUseCase {
  const DeleteLabelUseCase(this._labels, this._contacts, this._logger);

  final LabelRepository _labels;
  final ContactRepository _contacts;
  final LoggerApplicationService _logger;

  Future<void> execute(String id, {DateTime? now}) async {
    final all = await _contacts.listAll();
    final touched = [
      for (final c in all)
        if (c.labelIds.any((l) => l.value == id))
          c.copyWith(
            labelIds: {...c.labelIds}..removeWhere((l) => l.value == id),
            updatedAt: now ?? DateTime.now(),
          ),
    ];
    if (touched.isNotEmpty) await _contacts.saveAll(touched);
    await _labels.delete(id);
    // `contacts.count` = les fiches qui ont perdu l'étiquette. C'est ce chiffre
    // que l'utilisateur relira s'il trouve son filtrage vidé sans comprendre.
    await _logger.info('label.deleted', attrs: {'label.id': id, 'contacts.count': touched.length});
  }
}
