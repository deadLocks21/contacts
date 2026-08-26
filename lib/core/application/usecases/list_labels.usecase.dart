import 'package:contacts/core/application/dtos/label.dto.dart';
import 'package:contacts/core/application/services/text_normalizer.service.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/core/domain/services/label.repository.dart';

/// Les étiquettes du carnet, par ordre alphabétique, avec le nombre de fiches
/// que chacune porte (affiché dans le tiroir de navigation).
class ListLabelsUseCase {
  const ListLabelsUseCase(this._labels, this._contacts);

  final LabelRepository _labels;
  final ContactRepository _contacts;

  Future<List<LabelDto>> execute() async {
    final labels = await _labels.listAll();
    final contacts = await _contacts.listAll();

    final counts = <String, int>{};
    for (final c in contacts) {
      for (final id in c.labelIds) {
        counts.update(id.value, (n) => n + 1, ifAbsent: () => 1);
      }
    }

    final dtos = [
      for (final l in labels) LabelDto.fromDomain(l, contactCount: counts[l.id.value] ?? 0),
    ];
    dtos.sort((a, b) =>
        TextNormalizer.normalize(a.name).compareTo(TextNormalizer.normalize(b.name)));
    return dtos;
  }
}
