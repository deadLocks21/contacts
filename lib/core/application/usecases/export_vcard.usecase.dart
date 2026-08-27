import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:contacts/core/application/services/vcard.service.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/core/domain/services/label.repository.dart';

/// Exporte le carnet (ou une sélection) au format vCard 3.0.
class ExportVCardUseCase {
  const ExportVCardUseCase(this._contacts, this._labels, this._logger);

  final ContactRepository _contacts;
  final LabelRepository _labels;
  final LoggerApplicationService _logger;

  /// [ids] nul = tout le carnet, corbeille exclue.
  Future<String> execute({Iterable<String>? ids}) async {
    try {
      final all = await _contacts.listAll();
      final wanted = ids?.toSet();
      final selection = wanted == null
          ? all
          : [
              for (final c in all)
                if (wanted.contains(c.id.value)) c,
            ];
      final vcf = VCard.export(selection, labels: await _labels.listAll());
      // L'export sert aussi au partage d'une fiche : un `vcard.length` nul
      // explique un partage qui « n'envoie rien ».
      await _logger.info(
        'vcard.exported',
        attrs: {'contacts.count': selection.length, 'vcard.length': vcf.length},
      );
      return vcf;
    } catch (e, st) {
      await _logger.error('vcard.export.failed', error: e, stack: st);
      rethrow;
    }
  }
}
