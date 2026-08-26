import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/core/domain/model/entity_id.dart';

/// Site web associé à un contact.
class Website {
  final EntityId id;
  final String value;
  final WebsiteType type;
  final String? customLabel;

  Website({required this.id, required this.value, this.type = WebsiteType.profil, this.customLabel})
    : assert(value.trim().isNotEmpty, 'website cannot be empty');

  factory Website.create(
    String value, {
    WebsiteType type = WebsiteType.profil,
    String? customLabel,
  }) => Website(id: EntityId.generate(), value: value, type: type, customLabel: customLabel);

  String get label => type == WebsiteType.personnalise && (customLabel?.trim().isNotEmpty ?? false)
      ? customLabel!.trim()
      : type.label;

  /// URL navigable : on préfixe en `https://` ce qui a été saisi sans schéma.
  Uri get uri => Uri.parse(value.contains('://') ? value : 'https://$value');

  Website copyWith({String? value, WebsiteType? type, String? customLabel}) => Website(
    id: id,
    value: value ?? this.value,
    type: type ?? this.type,
    customLabel: customLabel ?? this.customLabel,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Website &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          value == other.value &&
          type == other.type &&
          customLabel == other.customLabel;

  @override
  int get hashCode => Object.hash(id, value, type, customLabel);
}
