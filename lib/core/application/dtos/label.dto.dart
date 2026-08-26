import 'package:contacts/core/domain/model/contact_label.dart';

/// Une étiquette et le nombre de contacts qui la portent (affiché dans le
/// tiroir de navigation).
class LabelDto {
  final String id;
  final String name;
  final int contactCount;

  const LabelDto({required this.id, required this.name, this.contactCount = 0});

  factory LabelDto.fromDomain(ContactLabel label, {int contactCount = 0}) =>
      LabelDto(id: label.id.value, name: label.name, contactCount: contactCount);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabelDto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          contactCount == other.contactCount;

  @override
  int get hashCode => Object.hash(id, name, contactCount);
}
