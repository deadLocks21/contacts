import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:contacts/core/application/services/text_normalizer.service.dart';
import 'package:contacts/core/domain/exceptions/contact_exception.dart';
import 'package:contacts/core/domain/services/label.repository.dart';

/// Renomme une étiquette, en refusant de créer un homonyme.
class RenameLabelUseCase {
  const RenameLabelUseCase(this._labels, this._logger);

  final LabelRepository _labels;
  final LoggerApplicationService _logger;

  Future<void> execute(String id, String newName, {DateTime? now}) async {
    final trimmed = newName.trim();
    final label = await _labels.getById(id);
    if (label == null) {
      await _logger.warn('label.rename.rejected', attrs: {'label.id': id, 'reason': 'not_found'});
      throw LabelNotFoundException(id);
    }
    if (trimmed.isEmpty) return;

    final normalized = TextNormalizer.normalize(trimmed);
    final existing = await _labels.listAll();
    if (existing.any((l) => l.id.value != id && TextNormalizer.normalize(l.name) == normalized)) {
      await _logger.warn('label.rename.rejected', attrs: {'label.id': id, 'reason': 'duplicate'});
      throw LabelAlreadyExistsException(trimmed);
    }
    await _labels.save(label.rename(trimmed, now: now));
    await _logger.info('label.renamed', attrs: {'label.id': id});
  }
}
