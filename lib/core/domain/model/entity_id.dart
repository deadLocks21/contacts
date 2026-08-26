import 'package:uuid/uuid.dart';

/// Identifiant d'une entité du carnet.
///
/// **Volontairement ouvert** : la source de vérité est le carnet d'adresses du
/// système, dont les identifiants n'ont pas de format garanti — Android rend
/// des entiers (« 42 »), iOS des chaînes opaques. Les valider comme des UUID
/// ferait échouer la lecture du premier contact venu.
///
/// [generate] reste disponible pour les entités créées localement, avant leur
/// insertion dans le carnet système.
class EntityId {
  final String value;

  const EntityId._(this.value);

  factory EntityId(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('An entity id cannot be empty');
    }
    return EntityId._(value.trim());
  }

  factory EntityId.generate() => EntityId._(const Uuid().v4());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntityId && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
