import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/core/domain/model/entity_id.dart';

/// Date importante (anniversaire, anniversaire de mariage…).
///
/// L'année est facultative : Google Contacts accepte « 14 février » sans année.
/// On la matérialise par [year] nul, la date restant portée par [month]/[day].
class ContactEvent {
  final EntityId id;
  final int? year;
  final int month;
  final int day;
  final EventType type;
  final String? customLabel;

  ContactEvent({
    required this.id,
    required this.month,
    required this.day,
    this.year,
    this.type = EventType.anniversaire,
    this.customLabel,
  }) : assert(month >= 1 && month <= 12, 'month out of range'),
       assert(day >= 1 && day <= 31, 'day out of range');

  factory ContactEvent.create({
    required int month,
    required int day,
    int? year,
    EventType type = EventType.anniversaire,
    String? customLabel,
  }) => ContactEvent(
    id: EntityId.generate(),
    month: month,
    day: day,
    year: year,
    type: type,
    customLabel: customLabel,
  );

  factory ContactEvent.fromDate(
    DateTime date, {
    EventType type = EventType.anniversaire,
    bool withYear = true,
  }) => ContactEvent.create(
    month: date.month,
    day: date.day,
    year: withYear ? date.year : null,
    type: type,
  );

  String get label => type == EventType.personnalise && (customLabel?.trim().isNotEmpty ?? false)
      ? customLabel!.trim()
      : type.label;

  bool get isBirthday => type == EventType.anniversaire;

  /// Prochaine occurrence à partir de [from] — sert au tri des anniversaires.
  DateTime nextOccurrence(DateTime from) {
    final thisYear = DateTime(from.year, month, day);
    return thisYear.isBefore(DateTime(from.year, from.month, from.day))
        ? DateTime(from.year + 1, month, day)
        : thisYear;
  }

  /// Âge atteint à la prochaine occurrence, si l'année de naissance est connue.
  int? ageAt(DateTime from) => year == null ? null : nextOccurrence(from).year - year!;

  ContactEvent copyWith({int? year, int? month, int? day, EventType? type, String? customLabel}) =>
      ContactEvent(
        id: id,
        year: year ?? this.year,
        month: month ?? this.month,
        day: day ?? this.day,
        type: type ?? this.type,
        customLabel: customLabel ?? this.customLabel,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          year == other.year &&
          month == other.month &&
          day == other.day &&
          type == other.type &&
          customLabel == other.customLabel;

  @override
  int get hashCode => Object.hash(id, year, month, day, type, customLabel);
}
