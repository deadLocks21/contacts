import 'package:contacts/core/application/dtos/contact_list.dto.dart';
import 'package:contacts/core/application/services/contact_grouping.service.dart';
import 'package:contacts/core/application/services/contact_mapper.service.dart';
import 'package:contacts/core/domain/model/app_settings.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';

/// La liste d'accueil : contacts hors corbeille, triés et découpés en sections.
///
/// [labelId] restreint la liste à une étiquette (le tiroir de navigation) ;
/// [starredOnly] à la vue « Favoris ». Dans ces deux vues filtrées, Google
/// n'épingle plus de section « Favoris » en tête — elle ferait doublon.
class ListContactsUseCase {
  const ListContactsUseCase(this._contacts);

  final ContactRepository _contacts;

  Future<ContactListDto> execute({
    required AppSettings settings,
    String? labelId,
    bool starredOnly = false,
  }) async {
    var contacts = await _contacts.listAll();
    if (labelId != null) {
      contacts = contacts.where((c) => c.labelIds.any((l) => l.value == labelId)).toList();
    }
    if (starredOnly) {
      contacts = contacts.where((c) => c.starred).toList();
    }

    final summaries = [
      for (final c in contacts)
        ContactMapper.summary(c, nameFormat: settings.nameFormat, sortOrder: settings.sortOrder),
    ]..sort(ContactGrouping.compare);

    final sections = ContactGrouping.sections(
      summaries,
      pinFavorites: labelId == null && !starredOnly,
    );

    return ContactListDto(
      sections: sections,
      all: summaries,
      alphabet: ContactGrouping.alphabetIndex(sections),
    );
  }
}
