import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/core/domain/model/uuid_value.dart';

/// Numéro de téléphone d'un contact, avec son libellé.
class PhoneNumber {
  final UuidValue id;
  final String value;
  final PhoneType type;

  /// Libellé saisi à la main, seulement quand [type] vaut `personnalise`.
  final String? customLabel;

  PhoneNumber({
    required this.id,
    required this.value,
    this.type = PhoneType.mobile,
    this.customLabel,
  }) : assert(value.trim().isNotEmpty, 'phone number cannot be empty');

  factory PhoneNumber.create(
    String value, {
    PhoneType type = PhoneType.mobile,
    String? customLabel,
  }) => PhoneNumber(id: UuidValue.generate(), value: value, type: type, customLabel: customLabel);

  String get label => type == PhoneType.personnalise && (customLabel?.trim().isNotEmpty ?? false)
      ? customLabel!.trim()
      : type.label;

  /// Chiffres seuls — sert à comparer deux numéros écrits différemment
  /// (« 06 12 34 56 78 » et « +33612345678 » partagent les 9 derniers chiffres).
  String get digits => value.replaceAll(RegExp(r'\D'), '');

  PhoneNumber copyWith({String? value, PhoneType? type, String? customLabel}) => PhoneNumber(
    id: id,
    value: value ?? this.value,
    type: type ?? this.type,
    customLabel: customLabel ?? this.customLabel,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoneNumber &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          value == other.value &&
          type == other.type &&
          customLabel == other.customLabel;

  @override
  int get hashCode => Object.hash(id, value, type, customLabel);
}
