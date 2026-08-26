import 'package:contacts/core/application/dtos/contact_list.dto.dart';
import 'package:contacts/core/application/services/contact_grouping.service.dart';
import 'package:contacts/core/application/services/contact_mapper.service.dart';
import 'package:contacts/core/domain/model/app_settings.dart';
import 'package:contacts/core/domain/model/contact.dart';
import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';

/// La liste d'accueil : contacts hors corbeille, triés et découpés en sections.
///
/// [labelId] restreint la liste à une étiquette, [starredOnly] aux favoris, et
/// [filters] applique les puces de filtre (téléphone, e-mail, société). Les
/// puces se cumulent en ET, comme chez Google.
class ListContactsUseCase {
  const ListContactsUseCase(this._contacts);

  final ContactRepository _contacts;

  Future<ContactListDto> execute({
    required AppSettings settings,
    String? labelId,
    bool starredOnly = false,
    Set<ContactFilter> filters = const {},
  }) async {
    var contacts = await _contacts.listAll();
    if (labelId != null) {
      contacts = contacts.where((c) => c.labelIds.any((l) => l.value == labelId)).toList();
    }
    if (starredOnly) {
      contacts = contacts.where((c) => c.starred).toList();
    }
    for (final filter in filters) {
      contacts = contacts.where((c) => _matches(c, filter)).toList();
    }

    final summaries = [
      for (final c in contacts)
        ContactMapper.summary(c, nameFormat: settings.nameFormat, sortOrder: settings.sortOrder),
    ]..sort(ContactGrouping.compare);

    final sections = ContactGrouping.sections(summaries);

    return ContactListDto(
      sections: sections,
      all: summaries,
      alphabet: ContactGrouping.alphabetIndex(sections),
    );
  }

  static bool _matches(Contact contact, ContactFilter filter) => switch (filter) {
    ContactFilter.avecTelephone => contact.phones.isNotEmpty,
    ContactFilter.avecEmail => contact.emails.isNotEmpty,
    ContactFilter.avecSociete => (contact.company?.trim().isNotEmpty ?? false),
  };
}
