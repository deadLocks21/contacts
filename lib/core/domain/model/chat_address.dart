import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/core/domain/model/entity_id.dart';

/// Identifiant de messagerie instantanée.
class ChatAddress {
  final EntityId id;
  final String value;
  final ChatType type;
  final String? customLabel;

  ChatAddress({
    required this.id,
    required this.value,
    this.type = ChatType.hangouts,
    this.customLabel,
  }) : assert(value.trim().isNotEmpty, 'chat address cannot be empty');

  factory ChatAddress.create(
    String value, {
    ChatType type = ChatType.hangouts,
    String? customLabel,
  }) => ChatAddress(id: EntityId.generate(), value: value, type: type, customLabel: customLabel);

  String get label => type == ChatType.personnalise && (customLabel?.trim().isNotEmpty ?? false)
      ? customLabel!.trim()
      : type.label;

  ChatAddress copyWith({String? value, ChatType? type, String? customLabel}) => ChatAddress(
    id: id,
    value: value ?? this.value,
    type: type ?? this.type,
    customLabel: customLabel ?? this.customLabel,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatAddress &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          value == other.value &&
          type == other.type &&
          customLabel == other.customLabel;

  @override
  int get hashCode => Object.hash(id, value, type, customLabel);
}
