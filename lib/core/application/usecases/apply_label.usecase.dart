import 'package:contacts/core/domain/model/uuid_value.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';

/// Pose ou retire une étiquette sur un lot de fiches (sélection multiple, ou
/// menu « Modifier les étiquettes » d'une fiche).
class ApplyLabelUseCase {
  const ApplyLabelUseCase(this._contacts);

  final ContactRepository _contacts;

  Future<void> execute(
    Iterable<String> contactIds,
    String labelId, {
    required bool apply,
    DateTime? now,
  }) async {
    final wanted = contactIds.toSet();
    final label = UuidValue.parse(labelId);
    final all = await _contacts.listAll(includeTrashed: true);

    final updates = [
      for (final c in all)
        if (wanted.contains(c.id.value) && c.labelIds.contains(label) != apply)
          c.copyWith(
            labelIds: apply ? {...c.labelIds, label} : ({...c.labelIds}..remove(label)),
            updatedAt: now ?? DateTime.now(),
          ),
    ];
    if (updates.isEmpty) return;
    await _contacts.saveAll(updates);
  }
}
