import 'package:contacts/core/domain/model/contact.dart';
import 'package:contacts/core/domain/model/contact_name.dart';
import 'package:contacts/core/domain/model/email_address.dart';
import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/core/domain/model/phone_number.dart';
import 'package:contacts/core/domain/model/uuid_value.dart';

/// Horodatage fixe : les tests ne doivent pas dépendre de l'heure qu'il est.
final testNow = DateTime.utc(2026, 3, 15, 10);

/// Fabrique une fiche minimale, complétée à la demande.
Contact aContact({
  String? first,
  String? last,
  String? company,
  String? jobTitle,
  List<String> phones = const [],
  List<String> emails = const [],
  String? notes,
  bool starred = false,
  Set<UuidValue> labelIds = const {},
  DateTime? createdAt,
  DateTime? deletedAt,
}) {
  final at = createdAt ?? testNow;
  return Contact(
    id: UuidValue.generate(),
    name: ContactName(first: first, last: last),
    company: company,
    jobTitle: jobTitle,
    phones: [for (final p in phones) PhoneNumber.create(p)],
    emails: [for (final e in emails) EmailAddress.create(e, type: EmailType.domicile)],
    notes: notes,
    starred: starred,
    labelIds: labelIds,
    createdAt: at,
    updatedAt: at,
    deletedAt: deletedAt,
  );
}
