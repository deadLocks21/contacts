import 'package:contacts/core/application/dtos/contact_summary.dto.dart';

/// Un anniversaire à venir, avec le nombre de jours qui en séparent.
class UpcomingBirthdayDto {
  final ContactSummaryDto contact;

  /// Date affichée (« 14 mars »).
  final String date;

  /// Jours restants — 0 = aujourd'hui.
  final int daysUntil;

  /// Âge atteint, quand l'année de naissance est connue.
  final int? age;

  const UpcomingBirthdayDto({
    required this.contact,
    required this.date,
    required this.daysUntil,
    this.age,
  });

  /// Phrase affichée sous le nom (« Aujourd'hui », « Dans 3 jours »).
  String get whenLabel => switch (daysUntil) {
    0 => "Aujourd'hui",
    1 => 'Demain',
    _ => 'Dans $daysUntil jours',
  };
}

/// Le contenu de l'onglet « Faits marquants » : les favoris, les anniversaires
/// qui approchent, et les fiches récemment ajoutées ou modifiées.
class HighlightsDto {
  final List<ContactSummaryDto> favorites;
  final List<UpcomingBirthdayDto> birthdays;
  final List<ContactSummaryDto> recents;

  const HighlightsDto({
    this.favorites = const [],
    this.birthdays = const [],
    this.recents = const [],
  });

  static const empty = HighlightsDto();

  bool get isEmpty => favorites.isEmpty && birthdays.isEmpty && recents.isEmpty;
}
