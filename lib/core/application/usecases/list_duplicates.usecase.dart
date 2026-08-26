import 'package:contacts/core/application/dtos/duplicate_group.dto.dart';
import 'package:contacts/core/application/services/contact_mapper.service.dart';
import 'package:contacts/core/application/services/duplicate_detection.service.dart';
import 'package:contacts/core/domain/model/app_settings.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';

/// Les groupes de fiches qui semblent décrire la même personne — le contenu de
/// « Fusionner et corriger ».
class ListDuplicatesUseCase {
  const ListDuplicatesUseCase(this._contacts);

  final ContactRepository _contacts;

  Future<List<DuplicateGroupDto>> execute({required AppSettings settings}) async {
    final groups = DuplicateDetection.find(
      await _contacts.listAll(),
      nameFormat: settings.nameFormat,
    );
    return [
      for (final g in groups)
        DuplicateGroupDto(
          key: g.key,
          reason: g.reason,
          contacts: [
            for (final c in g.contacts)
              ContactMapper.summary(
                c,
                nameFormat: settings.nameFormat,
                sortOrder: settings.sortOrder,
              ),
          ],
        ),
    ];
  }
}
