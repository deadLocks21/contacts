import 'package:contacts/core/application/dtos/trash_entry.dto.dart';
import 'package:contacts/core/application/services/contact_mapper.service.dart';
import 'package:contacts/core/application/services/date_label.service.dart';
import 'package:contacts/core/domain/model/app_settings.dart';
import 'package:contacts/core/domain/model/contact.dart';
import 'package:contacts/core/domain/services/trash.repository.dart';

/// Le contenu de la corbeille, du plus récemment supprimé au plus ancien.
class ListTrashUseCase {
  const ListTrashUseCase(this._trash);

  final TrashRepository _trash;

  Future<List<TrashEntryDto>> execute({required AppSettings settings, DateTime? now}) async {
    final at = now ?? DateTime.now();
    final trashed = await _trash.listAll();
    trashed.sort((a, b) => (b.deletedAt ?? b.updatedAt).compareTo(a.deletedAt ?? a.updatedAt));

    return [
      for (final c in trashed)
        TrashEntryDto(
          contact: ContactMapper.summary(
            c,
            nameFormat: settings.nameFormat,
            sortOrder: settings.sortOrder,
          ),
          daysLeft: _daysLeft(c, at),
          countdown: DateLabel.daysLeft(_daysLeft(c, at)),
        ),
    ];
  }

  static int _daysLeft(Contact contact, DateTime at) {
    final purge = contact.purgeAt;
    if (purge == null) return 0;
    final days = purge.difference(at).inHours / 24;
    return days.ceil().clamp(0, Contact.trashRetention.inDays);
  }
}
