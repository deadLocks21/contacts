import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/core/domain/model/uuid_value.dart';

/// Lien déclaré vers une autre personne (« Conjoint : Marie »).
/// La personne est un simple texte libre — Google Contacts ne référence pas
/// un autre contact ici.
class Relation {
  final UuidValue id;
  final String value;
  final RelationType type;
  final String? customLabel;

  Relation({
    required this.id,
    required this.value,
    this.type = RelationType.ami,
    this.customLabel,
  }) : assert(value.trim().isNotEmpty, 'relation cannot be empty');

  factory Relation.create(String value, {RelationType type = RelationType.ami, String? customLabel}) =>
      Relation(id: UuidValue.generate(), value: value, type: type, customLabel: customLabel);

  String get label =>
      type == RelationType.personnalise && (customLabel?.trim().isNotEmpty ?? false)
          ? customLabel!.trim()
          : type.label;

  Relation copyWith({String? value, RelationType? type, String? customLabel}) => Relation(
    id: id,
    value: value ?? this.value,
    type: type ?? this.type,
    customLabel: customLabel ?? this.customLabel,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Relation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          value == other.value &&
          type == other.type &&
          customLabel == other.customLabel;

  @override
  int get hashCode => Object.hash(id, value, type, customLabel);
}
