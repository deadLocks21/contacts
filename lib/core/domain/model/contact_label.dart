import 'package:contacts/core/domain/model/uuid_value.dart';

/// Étiquette (« label » Google) — un groupe nommé auquel des contacts
/// appartiennent. Un contact peut porter plusieurs étiquettes.
class ContactLabel {
  final UuidValue id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContactLabel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(name.trim().isNotEmpty, 'label name cannot be empty');

  factory ContactLabel.create(String name, {DateTime? now}) {
    final at = now ?? DateTime.now();
    return ContactLabel(id: UuidValue.generate(), name: name.trim(), createdAt: at, updatedAt: at);
  }

  ContactLabel rename(String newName, {DateTime? now}) => ContactLabel(
    id: id,
    name: newName.trim(),
    createdAt: createdAt,
    updatedAt: now ?? DateTime.now(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactLabel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
