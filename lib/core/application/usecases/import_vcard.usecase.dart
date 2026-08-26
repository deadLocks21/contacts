import 'package:contacts/core/application/services/text_normalizer.service.dart';
import 'package:contacts/core/application/services/vcard.service.dart';
import 'package:contacts/core/domain/model/contact_label.dart';
import 'package:contacts/core/domain/model/entity_id.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/core/domain/services/label.repository.dart';

/// Résultat d'un import, tel qu'annoncé à l'utilisateur.
typedef ImportReport = ({int imported, int labelsCreated});

/// Importe un fichier vCard.
///
/// Les fiches sont **ajoutées** sans écraser l'existant : Google fait de même
/// et laisse « Fusionner et corriger » réconcilier les doublons éventuels.
/// Les étiquettes citées (`CATEGORIES`) qui n'existent pas encore sont créées.
class ImportVCardUseCase {
  const ImportVCardUseCase(this._contacts, this._labels);

  final ContactRepository _contacts;
  final LabelRepository _labels;

  Future<ImportReport> execute(String source, {DateTime? now}) async {
    final at = now ?? DateTime.now();
    final parsed = VCard.parse(source, now: at);

    final existing = await _labels.listAll();
    final byName = {for (final l in existing) TextNormalizer.normalize(l.name): l};
    var labelsCreated = 0;

    final toSave = <ContactLabel>[];
    for (final entry in parsed) {
      for (final name in entry.labelNames) {
        final key = TextNormalizer.normalize(name);
        if (key.isEmpty || byName.containsKey(key)) continue;
        final label = ContactLabel.create(name, now: at);
        byName[key] = label;
        toSave.add(label);
        labelsCreated++;
      }
    }
    for (final label in toSave) {
      await _labels.save(label);
    }

    final contacts = [
      for (final entry in parsed)
        entry.contact.copyWith(
          labelIds: <EntityId>{
            for (final name in entry.labelNames)
              if (byName[TextNormalizer.normalize(name)] != null)
                byName[TextNormalizer.normalize(name)]!.id,
          },
          updatedAt: at,
        ),
    ];
    await _contacts.saveAll(contacts);

    return (imported: contacts.length, labelsCreated: labelsCreated);
  }
}
