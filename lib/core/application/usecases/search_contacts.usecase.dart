import 'package:contacts/core/application/dtos/contact_summary.dto.dart';
import 'package:contacts/core/application/services/contact_mapper.service.dart';
import 'package:contacts/core/application/services/contact_search.service.dart';
import 'package:contacts/core/domain/model/app_settings.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';

/// Recherche dans le carnet (corbeille exclue), résultats classés par
/// pertinence — l'ordre alphabétique ne s'applique pas ici.
class SearchContactsUseCase {
  const SearchContactsUseCase(this._contacts);

  final ContactRepository _contacts;

  Future<List<ContactSummaryDto>> execute(String query, {required AppSettings settings}) async {
    if (query.trim().isEmpty) return const [];
    final matches = ContactSearch.run(
      await _contacts.listAll(),
      query,
      nameFormat: settings.nameFormat,
    );
    return [
      for (final c in matches)
        ContactMapper.summary(c, nameFormat: settings.nameFormat, sortOrder: settings.sortOrder),
    ];
  }
}
