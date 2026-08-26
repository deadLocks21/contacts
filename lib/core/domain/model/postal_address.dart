import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/core/domain/model/uuid_value.dart';

/// Adresse postale structurée — les six champs du formulaire Google Contacts.
class PostalAddress {
  final UuidValue id;
  final String? street;
  final String? city;
  final String? postcode;
  final String? region;
  final String? country;
  final String? poBox;
  final AddressType type;
  final String? customLabel;

  const PostalAddress({
    required this.id,
    this.street,
    this.city,
    this.postcode,
    this.region,
    this.country,
    this.poBox,
    this.type = AddressType.domicile,
    this.customLabel,
  });

  factory PostalAddress.create({
    String? street,
    String? city,
    String? postcode,
    String? region,
    String? country,
    String? poBox,
    AddressType type = AddressType.domicile,
    String? customLabel,
  }) => PostalAddress(
    id: UuidValue.generate(),
    street: street,
    city: city,
    postcode: postcode,
    region: region,
    country: country,
    poBox: poBox,
    type: type,
    customLabel: customLabel,
  );

  String get label =>
      type == AddressType.personnalise && (customLabel?.trim().isNotEmpty ?? false)
          ? customLabel!.trim()
          : type.label;

  bool get isEmpty => formatted.isEmpty;

  /// Adresse sur une ligne, dans l'ordre postal français.
  String get formatted => [
    poBox,
    street,
    [postcode, city].map((p) => p?.trim() ?? '').where((p) => p.isNotEmpty).join(' '),
    region,
    country,
  ].map((p) => p?.trim() ?? '').where((p) => p.isNotEmpty).join(', ');

  /// Adresse sur plusieurs lignes, telle qu'affichée sur la fiche.
  String get multiline => [
    poBox,
    street,
    [postcode, city].map((p) => p?.trim() ?? '').where((p) => p.isNotEmpty).join(' '),
    region,
    country,
  ].map((p) => p?.trim() ?? '').where((p) => p.isNotEmpty).join('\n');

  PostalAddress copyWith({
    String? street,
    String? city,
    String? postcode,
    String? region,
    String? country,
    String? poBox,
    AddressType? type,
    String? customLabel,
  }) => PostalAddress(
    id: id,
    street: street ?? this.street,
    city: city ?? this.city,
    postcode: postcode ?? this.postcode,
    region: region ?? this.region,
    country: country ?? this.country,
    poBox: poBox ?? this.poBox,
    type: type ?? this.type,
    customLabel: customLabel ?? this.customLabel,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostalAddress && runtimeType == other.runtimeType && id == other.id && formatted == other.formatted && type == other.type;

  @override
  int get hashCode => Object.hash(id, formatted, type);
}
