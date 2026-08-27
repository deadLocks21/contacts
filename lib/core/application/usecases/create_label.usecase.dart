import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:contacts/core/application/services/text_normalizer.service.dart';
import 'package:contacts/core/domain/exceptions/contact_exception.dart';
import 'package:contacts/core/domain/model/contact_label.dart';
import 'package:contacts/core/domain/services/label.repository.dart';

/// Crée une étiquette. Le nom doit être libre : Google refuse deux étiquettes
/// homonymes, la comparaison ignorant casse et accents.
class CreateLabelUseCase {
  const CreateLabelUseCase(this._labels, this._logger);

  final LabelRepository _labels;
  final LoggerApplicationService _logger;

  /// Renvoie l'identifiant de l'étiquette créée.
  Future<String> execute(String name, {DateTime? now}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      await _logger.warn('label.create.rejected', attrs: {'reason': 'empty'});
      throw const LabelAlreadyExistsException('');
    }
    final existing = await _labels.listAll();
    final normalized = TextNormalizer.normalize(trimmed);
    if (existing.any((l) => TextNormalizer.normalize(l.name) == normalized)) {
      await _logger.warn('label.create.rejected', attrs: {'reason': 'duplicate'});
      throw LabelAlreadyExistsException(trimmed);
    }
    final label = ContactLabel.create(trimmed, now: now);
    await _labels.save(label);
    await _logger.info('label.created', attrs: {'label.id': label.id.value});
    return label.id.value;
  }
}
