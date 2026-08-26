import 'package:contacts/core/application/services/vcard.service.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/core/domain/services/label.repository.dart';

/// Exporte le carnet (ou une sélection) au format vCard 3.0.
class ExportVCardUseCase {
  const ExportVCardUseCase(this._contacts, this._labels);

  final ContactRepository _contacts;
  final LabelRepository _labels;

  /// [ids] nul = tout le carnet, corbeille exclue.
  Future<String> execute({Iterable<String>? ids}) async {
    final all = await _contacts.listAll();
    final wanted = ids?.toSet();
    final selection = wanted == null
        ? all
        : [
            for (final c in all)
              if (wanted.contains(c.id.value)) c,
          ];
    return VCard.export(selection, labels: await _labels.listAll());
  }
}
