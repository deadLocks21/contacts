import 'package:contacts/core/application/dtos/contact_field.dto.dart';
import 'package:contacts/core/application/dtos/label.dto.dart';

/// La fiche complète, prête à afficher : plus aucune règle à appliquer côté UI.
class ContactDetailDto {
  final String id;
  final String displayName;

  /// Nom mis en avant sous la photo quand il diffère du nom affiché
  /// (surnom, nom phonétique) — vide sinon.
  final String? nickname;
  final String initials;
  final String? photoPath;
  final bool starred;

  /// « Poste, Société », ou vide.
  final String subtitle;

  final List<ContactFieldDto> phones;
  final List<ContactFieldDto> emails;
  final List<ContactFieldDto> addresses;
  final List<ContactFieldDto> websites;
  final List<ContactFieldDto> events;
  final List<ContactFieldDto> relations;
  final List<ContactFieldDto> chats;
  final String? notes;
  final List<LabelDto> labels;

  final bool sendToVoicemail;
  final String? customRingtone;

  /// Vrai si la fiche est à la corbeille : la page passe alors en mode
  /// « restaurer / supprimer définitivement ».
  final bool isTrashed;

  /// Numéro appelé par défaut par les boutons d'action (le premier saisi).
  String? get primaryPhone => phones.firstOrNull?.rawValue;

  /// Adresse e-mail utilisée par défaut par le bouton « E-mail ».
  String? get primaryEmail => emails.firstOrNull?.rawValue;

  /// Vrai quand la fiche ne contient rien d'autre que son nom.
  bool get hasNoDetails =>
      phones.isEmpty &&
      emails.isEmpty &&
      addresses.isEmpty &&
      websites.isEmpty &&
      events.isEmpty &&
      relations.isEmpty &&
      chats.isEmpty &&
      (notes == null || notes!.isEmpty);

  const ContactDetailDto({
    required this.id,
    required this.displayName,
    required this.initials,
    required this.subtitle,
    this.nickname,
    this.photoPath,
    this.starred = false,
    this.phones = const [],
    this.emails = const [],
    this.addresses = const [],
    this.websites = const [],
    this.events = const [],
    this.relations = const [],
    this.chats = const [],
    this.notes,
    this.labels = const [],
    this.sendToVoicemail = false,
    this.customRingtone,
    this.isTrashed = false,
  });
}
