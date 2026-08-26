import 'package:contacts/core/application/dtos/highlights.dto.dart';
import 'package:contacts/core/application/services/contact_grouping.service.dart';
import 'package:contacts/core/application/services/contact_mapper.service.dart';
import 'package:contacts/core/application/services/date_label.service.dart';
import 'package:contacts/core/domain/model/app_settings.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';

/// Compose l'onglet « Faits marquants ».
class ListHighlightsUseCase {
  const ListHighlightsUseCase(this._contacts);

  final ContactRepository _contacts;

  /// Fenêtre des anniversaires annoncés — au-delà, l'information n'est pas
  /// encore actionnable.
  static const birthdayHorizon = Duration(days: 30);

  /// Nombre de fiches récentes affichées.
  static const recentsCount = 5;

  Future<HighlightsDto> execute({required AppSettings settings, DateTime? now}) async {
    final at = now ?? DateTime.now();
    final contacts = await _contacts.listAll();

    final favorites = [
      for (final c in contacts)
        if (c.starred)
          ContactMapper.summary(c, nameFormat: settings.nameFormat, sortOrder: settings.sortOrder),
    ]..sort(ContactGrouping.compare);

    final birthdays = <UpcomingBirthdayDto>[];
    for (final contact in contacts) {
      final birthday = contact.birthday;
      if (birthday == null) continue;
      final next = birthday.nextOccurrence(at);
      final days = next.difference(DateTime(at.year, at.month, at.day)).inDays;
      if (days > birthdayHorizon.inDays) continue;
      birthdays.add(
        UpcomingBirthdayDto(
          contact: ContactMapper.summary(
            contact,
            nameFormat: settings.nameFormat,
            sortOrder: settings.sortOrder,
          ),
          date: DateLabel.eventDate(birthday.day, birthday.month, null),
          daysUntil: days,
          age: birthday.ageAt(at),
        ),
      );
    }
    birthdays.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));

    // « Récents » = les dernières fiches touchées, création comme modification :
    // ce sont celles qu'on cherche à rouvrir juste après les avoir saisies.
    final recent = [...contacts]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final recents = [
      for (final c in recent.take(recentsCount))
        ContactMapper.summary(c, nameFormat: settings.nameFormat, sortOrder: settings.sortOrder),
    ];

    return HighlightsDto(favorites: favorites, birthdays: birthdays, recents: recents);
  }
}
