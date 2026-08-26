import 'package:contacts/core/domain/model/chat_address.dart';
import 'package:contacts/core/domain/model/contact.dart';
import 'package:contacts/core/domain/model/contact_event.dart';
import 'package:contacts/core/domain/model/contact_name.dart';
import 'package:contacts/core/domain/model/email_address.dart';
import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/core/domain/model/phone_number.dart';
import 'package:contacts/core/domain/model/postal_address.dart';
import 'package:contacts/core/domain/model/relation.dart';
import 'package:contacts/core/domain/model/entity_id.dart';
import 'package:contacts/core/domain/model/website.dart';

/// Brouillon d'un champ libellé (téléphone, e-mail, site…).
///
/// **Mutable, à dessein** : c'est l'état d'un formulaire, que l'UI modifie au
/// fil de la frappe. Rien de tout cela n'atteint le domaine avant l'appel à
/// [ContactDraft.toDomain], qui filtre les lignes vides.
class FieldDraft<T> {
  /// Identifiant de la ligne existante, nul pour une ligne ajoutée au formulaire.
  final String? id;
  String value;
  T type;
  String customLabel;

  FieldDraft({this.id, this.value = '', required this.type, this.customLabel = ''});

  bool get isEmpty => value.trim().isEmpty;
}

/// Brouillon d'une adresse postale (six champs).
class AddressDraft {
  final String? id;
  String street;
  String city;
  String postcode;
  String region;
  String country;
  String poBox;
  AddressType type;
  String customLabel;

  AddressDraft({
    this.id,
    this.street = '',
    this.city = '',
    this.postcode = '',
    this.region = '',
    this.country = '',
    this.poBox = '',
    this.type = AddressType.domicile,
    this.customLabel = '',
  });

  bool get isEmpty =>
      [street, city, postcode, region, country, poBox].every((f) => f.trim().isEmpty);
}

/// Brouillon d'une date importante. [year] nul = date sans année.
class EventDraft {
  final String? id;
  int? year;
  int? month;
  int? day;
  EventType type;
  String customLabel;

  EventDraft({
    this.id,
    this.year,
    this.month,
    this.day,
    this.type = EventType.anniversaire,
    this.customLabel = '',
  });

  bool get isEmpty => month == null || day == null;
}

/// État complet du formulaire d'édition d'un contact.
///
/// [id] nul = création. La conversion vers le domaine ([toDomain]) élague les
/// lignes vides : un champ ajouté puis laissé blanc n'est jamais enregistré.
class ContactDraft {
  final String? id;

  String prefix;
  String first;
  String middle;
  String last;
  String suffix;
  String phoneticFirst;
  String phoneticMiddle;
  String phoneticLast;
  String nickname;

  String company;
  String jobTitle;
  String department;

  String? photoPath;

  List<FieldDraft<PhoneType>> phones;
  List<FieldDraft<EmailType>> emails;
  List<AddressDraft> addresses;
  List<FieldDraft<WebsiteType>> websites;
  List<EventDraft> events;
  List<FieldDraft<RelationType>> relations;
  List<FieldDraft<ChatType>> chats;

  String notes;
  Set<String> labelIds;
  bool starred;

  ContactDraft({
    this.id,
    this.prefix = '',
    this.first = '',
    this.middle = '',
    this.last = '',
    this.suffix = '',
    this.phoneticFirst = '',
    this.phoneticMiddle = '',
    this.phoneticLast = '',
    this.nickname = '',
    this.company = '',
    this.jobTitle = '',
    this.department = '',
    this.photoPath,
    List<FieldDraft<PhoneType>>? phones,
    List<FieldDraft<EmailType>>? emails,
    List<AddressDraft>? addresses,
    List<FieldDraft<WebsiteType>>? websites,
    List<EventDraft>? events,
    List<FieldDraft<RelationType>>? relations,
    List<FieldDraft<ChatType>>? chats,
    this.notes = '',
    Set<String>? labelIds,
    this.starred = false,
  }) : phones = phones ?? [],
       emails = emails ?? [],
       addresses = addresses ?? [],
       websites = websites ?? [],
       events = events ?? [],
       relations = relations ?? [],
       chats = chats ?? [],
       labelIds = labelIds ?? {};

  /// Formulaire vierge, tel qu'ouvert par « Créer un contact » : une ligne
  /// téléphone et une ligne e-mail déjà présentes, comme chez Google.
  factory ContactDraft.blank({Set<String> labelIds = const {}}) => ContactDraft(
    phones: [FieldDraft(type: PhoneType.mobile)],
    emails: [FieldDraft(type: EmailType.domicile)],
    labelIds: {...labelIds},
  );

  factory ContactDraft.fromDomain(Contact c) => ContactDraft(
    id: c.id.value,
    prefix: c.name.prefix ?? '',
    first: c.name.first ?? '',
    middle: c.name.middle ?? '',
    last: c.name.last ?? '',
    suffix: c.name.suffix ?? '',
    phoneticFirst: c.name.phoneticFirst ?? '',
    phoneticMiddle: c.name.phoneticMiddle ?? '',
    phoneticLast: c.name.phoneticLast ?? '',
    nickname: c.name.nickname ?? '',
    company: c.company ?? '',
    jobTitle: c.jobTitle ?? '',
    department: c.department ?? '',
    photoPath: c.photoPath,
    phones: [
      for (final p in c.phones)
        FieldDraft(id: p.id.value, value: p.value, type: p.type, customLabel: p.customLabel ?? ''),
    ],
    emails: [
      for (final e in c.emails)
        FieldDraft(id: e.id.value, value: e.value, type: e.type, customLabel: e.customLabel ?? ''),
    ],
    addresses: [
      for (final a in c.addresses)
        AddressDraft(
          id: a.id.value,
          street: a.street ?? '',
          city: a.city ?? '',
          postcode: a.postcode ?? '',
          region: a.region ?? '',
          country: a.country ?? '',
          poBox: a.poBox ?? '',
          type: a.type,
          customLabel: a.customLabel ?? '',
        ),
    ],
    websites: [
      for (final w in c.websites)
        FieldDraft(id: w.id.value, value: w.value, type: w.type, customLabel: w.customLabel ?? ''),
    ],
    events: [
      for (final e in c.events)
        EventDraft(
          id: e.id.value,
          year: e.year,
          month: e.month,
          day: e.day,
          type: e.type,
          customLabel: e.customLabel ?? '',
        ),
    ],
    relations: [
      for (final r in c.relations)
        FieldDraft(id: r.id.value, value: r.value, type: r.type, customLabel: r.customLabel ?? ''),
    ],
    chats: [
      for (final ch in c.chats)
        FieldDraft(
          id: ch.id.value,
          value: ch.value,
          type: ch.type,
          customLabel: ch.customLabel ?? '',
        ),
    ],
    notes: c.notes ?? '',
    labelIds: {for (final l in c.labelIds) l.value},
    starred: c.starred,
  );

  static String? _clean(String s) => s.trim().isEmpty ? null : s.trim();

  static EntityId _idOf(String? id) => id == null ? EntityId.generate() : EntityId(id);

  /// Applique le brouillon sur [base] (édition) ou construit une fiche neuve
  /// (création). Les lignes vides sont écartées.
  Contact toDomain({Contact? base, DateTime? now}) {
    final at = now ?? DateTime.now();
    final name = ContactName(
      prefix: _clean(prefix),
      first: _clean(first),
      middle: _clean(middle),
      last: _clean(last),
      suffix: _clean(suffix),
      phoneticFirst: _clean(phoneticFirst),
      phoneticMiddle: _clean(phoneticMiddle),
      phoneticLast: _clean(phoneticLast),
      nickname: _clean(nickname),
    );

    final builtPhones = [
      for (final p in phones.where((p) => !p.isEmpty))
        PhoneNumber(
          id: _idOf(p.id),
          value: p.value.trim(),
          type: p.type,
          customLabel: _clean(p.customLabel),
        ),
    ];
    final builtEmails = [
      for (final e in emails.where((e) => !e.isEmpty))
        EmailAddress(
          id: _idOf(e.id),
          value: e.value.trim(),
          type: e.type,
          customLabel: _clean(e.customLabel),
        ),
    ];
    final builtAddresses = [
      for (final a in addresses.where((a) => !a.isEmpty))
        PostalAddress(
          id: _idOf(a.id),
          street: _clean(a.street),
          city: _clean(a.city),
          postcode: _clean(a.postcode),
          region: _clean(a.region),
          country: _clean(a.country),
          poBox: _clean(a.poBox),
          type: a.type,
          customLabel: _clean(a.customLabel),
        ),
    ];
    final builtWebsites = [
      for (final w in websites.where((w) => !w.isEmpty))
        Website(
          id: _idOf(w.id),
          value: w.value.trim(),
          type: w.type,
          customLabel: _clean(w.customLabel),
        ),
    ];
    final builtEvents = [
      for (final e in events.where((e) => !e.isEmpty))
        ContactEvent(
          id: _idOf(e.id),
          year: e.year,
          month: e.month!,
          day: e.day!,
          type: e.type,
          customLabel: _clean(e.customLabel),
        ),
    ];
    final builtRelations = [
      for (final r in relations.where((r) => !r.isEmpty))
        Relation(
          id: _idOf(r.id),
          value: r.value.trim(),
          type: r.type,
          customLabel: _clean(r.customLabel),
        ),
    ];
    final builtChats = [
      for (final c in chats.where((c) => !c.isEmpty))
        ChatAddress(
          id: _idOf(c.id),
          value: c.value.trim(),
          type: c.type,
          customLabel: _clean(c.customLabel),
        ),
    ];
    final builtLabels = {for (final l in labelIds) EntityId(l)};

    // Construction explicite plutôt que `copyWith` : le formulaire doit pouvoir
    // *vider* un champ, ce qu'un `copyWith` à paramètres nullables ne sait pas
    // exprimer (null y signifie « inchangé »). On repart donc de zéro en ne
    // reprenant de [base] que ce que le formulaire n'expose pas.
    return Contact(
      id: base?.id ?? (id == null ? EntityId.generate() : EntityId(id!)),
      name: name,
      company: _clean(company),
      jobTitle: _clean(jobTitle),
      department: _clean(department),
      photoPath: photoPath,
      phones: builtPhones,
      emails: builtEmails,
      addresses: builtAddresses,
      websites: builtWebsites,
      events: builtEvents,
      relations: builtRelations,
      chats: builtChats,
      notes: _clean(notes),
      labelIds: builtLabels,
      starred: starred,
      customRingtone: base?.customRingtone,
      sendToVoicemail: base?.sendToVoicemail ?? false,
      createdAt: base?.createdAt ?? at,
      updatedAt: at,
      deletedAt: base?.deletedAt,
    );
  }
}
