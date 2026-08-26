import 'package:contacts/core/application/services/text_normalizer.service.dart';
import 'package:contacts/core/domain/exceptions/contact_exception.dart';
import 'package:contacts/core/domain/model/contact_label.dart';
import 'package:contacts/core/domain/services/label.repository.dart';

/// Crée une étiquette. Le nom doit être libre : Google refuse deux étiquettes
/// homonymes, la comparaison ignorant casse et accents.
class CreateLabelUseCase {
  const CreateLabelUseCase(this._labels);

  final LabelRepository _labels;

  /// Renvoie l'identifiant de l'étiquette créée.
  Future<String> execute(String name, {DateTime? now}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw const LabelAlreadyExistsException('');
    final existing = await _labels.listAll();
    final normalized = TextNormalizer.normalize(trimmed);
    if (existing.any((l) => TextNormalizer.normalize(l.name) == normalized)) {
      throw LabelAlreadyExistsException(trimmed);
    }
    final label = ContactLabel.create(trimmed, now: now);
    await _labels.save(label);
    return label.id.value;
  }
}
