import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/core/domain/model/uuid_value.dart';

/// Adresse e-mail d'un contact, avec son libellé.
class EmailAddress {
  final UuidValue id;
  final String value;
  final EmailType type;
  final String? customLabel;

  EmailAddress({
    required this.id,
    required this.value,
    this.type = EmailType.domicile,
    this.customLabel,
  }) : assert(value.trim().isNotEmpty, 'email cannot be empty');

  factory EmailAddress.create(
    String value, {
    EmailType type = EmailType.domicile,
    String? customLabel,
  }) => EmailAddress(id: UuidValue.generate(), value: value, type: type, customLabel: customLabel);

  String get label => type == EmailType.personnalise && (customLabel?.trim().isNotEmpty ?? false)
      ? customLabel!.trim()
      : type.label;

  EmailAddress copyWith({String? value, EmailType? type, String? customLabel}) => EmailAddress(
    id: id,
    value: value ?? this.value,
    type: type ?? this.type,
    customLabel: customLabel ?? this.customLabel,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmailAddress &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          value == other.value &&
          type == other.type &&
          customLabel == other.customLabel;

  @override
  int get hashCode => Object.hash(id, value, type, customLabel);
}
