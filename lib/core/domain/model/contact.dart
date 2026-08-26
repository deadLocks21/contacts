import 'package:contacts/core/domain/model/chat_address.dart';
import 'package:contacts/core/domain/model/contact_event.dart';
import 'package:contacts/core/domain/model/contact_name.dart';
import 'package:contacts/core/domain/model/email_address.dart';
import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/core/domain/model/phone_number.dart';
import 'package:contacts/core/domain/model/postal_address.dart';
import 'package:contacts/core/domain/model/relation.dart';
import 'package:contacts/core/domain/model/entity_id.dart';
import 'package:contacts/core/domain/model/website.dart';

/// Une fiche du carnet d'adresses.
///
/// Suppression **logique** : [deletedAt] non nul = le contact est à la
/// corbeille, d'où il est restaurable pendant 30 jours (cf. [trashRetention]).
class Contact {
  final EntityId id;
  final ContactName name;
  final String? company;
  final String? jobTitle;
  final String? department;

  /// Chemin local de la photo, ou null (l'UI affiche alors une pastille colorée
  /// portant les initiales).
  final String? photoPath;

  final List<PhoneNumber> phones;
  final List<EmailAddress> emails;
  final List<PostalAddress> addresses;
  final List<Website> websites;
  final List<ContactEvent> events;
  final List<Relation> relations;
  final List<ChatAddress> chats;
  final String? notes;
  final Set<EntityId> labelIds;
  final bool starred;

  /// Sonnerie propre au contact (réglage de la fiche, menu « ⋮ »).
  final String? customRingtone;

  /// « Renvoyer vers la messagerie vocale » — les appels de ce contact ne
  /// font pas sonner l'appareil.
  final bool sendToVoicemail;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Durée de rétention à la corbeille avant purge définitive.
  static const trashRetention = Duration(days: 30);

  Contact({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.company,
    this.jobTitle,
    this.department,
    this.photoPath,
    this.phones = const [],
    this.emails = const [],
    this.addresses = const [],
    this.websites = const [],
    this.events = const [],
    this.relations = const [],
    this.chats = const [],
    this.notes,
    this.labelIds = const {},
    this.starred = false,
    this.customRingtone,
    this.sendToVoicemail = false,
    this.deletedAt,
  });

  factory Contact.create({
    ContactName name = ContactName.empty,
    String? company,
    String? jobTitle,
    List<PhoneNumber> phones = const [],
    List<EmailAddress> emails = const [],
    Set<EntityId> labelIds = const {},
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    return Contact(
      id: EntityId.generate(),
      name: name,
      company: company,
      jobTitle: jobTitle,
      phones: phones,
      emails: emails,
      labelIds: labelIds,
      createdAt: at,
      updatedAt: at,
    );
  }

  bool get isTrashed => deletedAt != null;

  /// Un contact sans nom se présente par sa société, à défaut par son premier
  /// e-mail ou téléphone — c'est ce que fait la liste de Google Contacts.
  String displayName(NameFormat format) {
    final n = name.displayName(format);
    if (n.isNotEmpty) return n;
    final fallbacks = [company?.trim(), emails.firstOrNull?.value, phones.firstOrNull?.value];
    return fallbacks.firstWhere((f) => f != null && f.isNotEmpty, orElse: () => '') ?? '';
  }

  /// Deuxième ligne de la liste et de la fiche : « Poste, Société ».
  ///
  /// La société en est retirée quand c'est elle qui sert de nom (fiche
  /// d'entreprise, sans personne derrière) : la répéter juste en dessous
  /// n'apprendrait rien.
  String get subtitle => [
    jobTitle?.trim(),
    if (!name.isEmpty) company?.trim(),
  ].where((p) => p != null && p.isNotEmpty).join(', ');

  /// Initiales de l'avatar ; retombe sur la société pour un contact sans nom.
  String get initials {
    final fromName = name.initials;
    if (fromName.isNotEmpty) return fromName;
    final c = company?.trim() ?? '';
    return c.isEmpty ? '' : c[0].toUpperCase();
  }

  /// Date de naissance, si elle a été saisie.
  ContactEvent? get birthday => events.where((e) => e.isBirthday).firstOrNull;

  /// Fiche « vide » : rien à afficher hormis d'éventuelles étiquettes. Sert à
  /// refuser l'enregistrement d'un formulaire jamais rempli.
  bool get isBlank =>
      name.isEmpty &&
      (company?.trim().isEmpty ?? true) &&
      (jobTitle?.trim().isEmpty ?? true) &&
      (notes?.trim().isEmpty ?? true) &&
      phones.isEmpty &&
      emails.isEmpty &&
      addresses.isEmpty &&
      websites.isEmpty &&
      events.isEmpty &&
      relations.isEmpty &&
      chats.isEmpty;

  /// Date de purge définitive (30 jours après la mise à la corbeille).
  DateTime? get purgeAt => deletedAt?.add(trashRetention);

  Contact copyWith({
    ContactName? name,
    String? company,
    String? jobTitle,
    String? department,
    String? photoPath,
    List<PhoneNumber>? phones,
    List<EmailAddress>? emails,
    List<PostalAddress>? addresses,
    List<Website>? websites,
    List<ContactEvent>? events,
    List<Relation>? relations,
    List<ChatAddress>? chats,
    String? notes,
    Set<EntityId>? labelIds,
    bool? starred,
    String? customRingtone,
    bool? sendToVoicemail,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearPhoto = false,
    bool clearDeletedAt = false,
    bool clearRingtone = false,
  }) {
    return Contact(
      id: id,
      name: name ?? this.name,
      company: company ?? this.company,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      phones: phones ?? this.phones,
      emails: emails ?? this.emails,
      addresses: addresses ?? this.addresses,
      websites: websites ?? this.websites,
      events: events ?? this.events,
      relations: relations ?? this.relations,
      chats: chats ?? this.chats,
      notes: notes ?? this.notes,
      labelIds: labelIds ?? this.labelIds,
      starred: starred ?? this.starred,
      customRingtone: clearRingtone ? null : (customRingtone ?? this.customRingtone),
      sendToVoicemail: sendToVoicemail ?? this.sendToVoicemail,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contact && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
