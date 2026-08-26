import 'dart:async';

import 'package:contacts/core/domain/model/chat_address.dart';
import 'package:contacts/core/domain/model/contact.dart';
import 'package:contacts/core/domain/model/contact_event.dart';
import 'package:contacts/core/domain/model/contact_name.dart';
import 'package:contacts/core/domain/model/email_address.dart';
import 'package:contacts/core/domain/model/entity_id.dart';
import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/core/domain/model/phone_number.dart';
import 'package:contacts/core/domain/model/postal_address.dart';
import 'package:contacts/core/domain/model/relation.dart';
import 'package:contacts/core/domain/model/website.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/infrastructure/contacts/contact_field_mapping.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;

/// Le carnet d'adresses du système — l'implémentation réelle du port.
///
/// Les fiches lues et écrites ici sont celles que voient le composeur, la
/// messagerie et toutes les autres apps : l'app n'a pas de carnet à elle.
///
/// Sans permission, [listAll] rend une liste vide plutôt que de lever : l'UI
/// propose alors d'ouvrir l'accès, ce qui est plus utile qu'une erreur.
class FlutterContactsContactRepository implements ContactRepository {
  FlutterContactsContactRepository() {
    // Le carnet change aussi depuis les autres apps : on relaie ses
    // notifications pour que la liste affichée ne mente jamais longtemps.
    _listener = () => _bump();
    fc.FlutterContacts.addListener(_listener);
  }

  final _controller = StreamController<int>.broadcast();
  late final void Function() _listener;
  var _revision = 0;

  void _bump() => _controller.add(++_revision);

  void dispose() {
    fc.FlutterContacts.removeListener(_listener);
    _controller.close();
  }

  @override
  Stream<int> get changes => _controller.stream;

  Future<bool> _ensurePermission({bool readonly = false}) async {
    final granted = await fc.FlutterContacts.requestPermission(readonly: readonly);
    if (granted) {
      // Les fiches d'un compte que le carnet masque par défaut restent des
      // contacts : les exclure ferait disparaître ce qu'une autre app a créé.
      fc.FlutterContacts.config.includeNonVisibleOnAndroid = true;
    }
    return granted;
  }

  @override
  Future<List<Contact>> listAll() async {
    if (!await _ensurePermission(readonly: true)) return const [];
    final contacts = await fc.FlutterContacts.getContacts(
      withProperties: true,
      withThumbnail: true,
      withGroups: true,
    );
    return [for (final c in contacts) _toDomain(c)];
  }

  @override
  Future<Contact?> getById(String id) async {
    if (!await _ensurePermission(readonly: true)) return null;
    final contact = await fc.FlutterContacts.getContact(
      id,
      withProperties: true,
      withPhoto: true,
      withGroups: true,
    );
    return contact == null ? null : _toDomain(contact);
  }

  @override
  Future<String> save(Contact contact) async {
    if (!await _ensurePermission()) return contact.id.value;

    // Une fiche peut porter un identifiant que le carnet ne connaît pas : soit
    // elle vient d'être créée, soit elle revient de la corbeille. Dans les deux
    // cas c'est une insertion, et c'est le système qui alloue l'identifiant.
    final existing = await fc.FlutterContacts.getContact(
      contact.id.value,
      withProperties: true,
      withGroups: true,
    );

    if (existing == null) {
      final inserted = await fc.FlutterContacts.insertContact(_toNative(contact, fc.Contact()));
      _bump();
      return inserted.id;
    }
    await fc.FlutterContacts.updateContact(_toNative(contact, existing));
    _bump();
    return existing.id;
  }

  @override
  Future<void> saveAll(Iterable<Contact> contacts) async {
    for (final contact in contacts) {
      await save(contact);
    }
  }

  @override
  Future<void> delete(Iterable<String> ids) async {
    if (ids.isEmpty) return;
    if (!await _ensurePermission()) return;
    await fc.FlutterContacts.deleteContacts([for (final id in ids) fc.Contact(id: id)]);
    _bump();
  }

  // ------------------------------------------------------------- lecture

  Contact _toDomain(fc.Contact c) {
    final organization = c.organizations.firstOrNull;
    final now = DateTime.now();
    // Le carnet n'expose pas d'identifiant par ligne : on en dérive un,
    // stable pour une fiche donnée, qui sert de clé d'affichage et d'édition.
    String fieldId(String kind, int index) => '${c.id}:$kind:$index';

    return Contact(
      id: EntityId(c.id),
      name: ContactName(
        prefix: _clean(c.name.prefix),
        first: _clean(c.name.first),
        middle: _clean(c.name.middle),
        last: _clean(c.name.last),
        suffix: _clean(c.name.suffix),
        phoneticFirst: _clean(c.name.firstPhonetic),
        phoneticMiddle: _clean(c.name.middlePhonetic),
        phoneticLast: _clean(c.name.lastPhonetic),
        nickname: _clean(c.name.nickname),
      ),
      company: _clean(organization?.company),
      jobTitle: _clean(organization?.title),
      department: _clean(organization?.department),
      photo: c.photo ?? c.thumbnail,
      phones: [
        for (var i = 0; i < c.phones.length; i++)
          if (_clean(c.phones[i].number) case final number?)
            PhoneNumber(
              id: EntityId(fieldId('phone', i)),
              value: number,
              type: phoneTypeFrom(c.phones[i].label),
              customLabel: _clean(c.phones[i].customLabel),
            ),
      ],
      emails: [
        for (var i = 0; i < c.emails.length; i++)
          if (_clean(c.emails[i].address) case final address?)
            EmailAddress(
              id: EntityId(fieldId('email', i)),
              value: address,
              type: emailTypeFrom(c.emails[i].label),
              customLabel: _clean(c.emails[i].customLabel),
            ),
      ],
      addresses: [
        for (var i = 0; i < c.addresses.length; i++)
          PostalAddress(
            id: EntityId(fieldId('address', i)),
            street: _clean(c.addresses[i].street),
            city: _clean(c.addresses[i].city),
            postcode: _clean(c.addresses[i].postalCode),
            region: _clean(c.addresses[i].state),
            country: _clean(c.addresses[i].country),
            poBox: _clean(c.addresses[i].pobox),
            type: addressTypeFrom(c.addresses[i].label),
            customLabel: _clean(c.addresses[i].customLabel),
          ),
      ],
      websites: [
        for (var i = 0; i < c.websites.length; i++)
          if (_clean(c.websites[i].url) case final url?)
            Website(
              id: EntityId(fieldId('website', i)),
              value: url,
              type: websiteTypeFrom(c.websites[i].label),
              customLabel: _clean(c.websites[i].customLabel),
            ),
      ],
      events: [
        for (var i = 0; i < c.events.length; i++)
          ContactEvent(
            id: EntityId(fieldId('event', i)),
            year: c.events[i].year,
            month: c.events[i].month,
            day: c.events[i].day,
            type: eventTypeFrom(c.events[i].label),
            customLabel: _clean(c.events[i].customLabel),
          ),
      ],
      // Les relations voyagent parmi les messageries, reconnaissables à leur
      // intitulé préfixé (cf. [relationLabelPrefix]).
      relations: [
        for (var i = 0; i < c.socialMedias.length; i++)
          if (c.socialMedias[i].customLabel.startsWith(relationLabelPrefix))
            if (_clean(c.socialMedias[i].userName) case final value?)
              Relation(
                id: EntityId(fieldId('relation', i)),
                value: value,
                type: RelationType.personnalise,
                customLabel: c.socialMedias[i].customLabel.substring(relationLabelPrefix.length),
              ),
      ],
      chats: [
        for (var i = 0; i < c.socialMedias.length; i++)
          if (!c.socialMedias[i].customLabel.startsWith(relationLabelPrefix))
            if (_clean(c.socialMedias[i].userName) case final userName?)
              ChatAddress(
                id: EntityId(fieldId('chat', i)),
                value: userName,
                type: chatTypeFrom(c.socialMedias[i].label),
                customLabel: _clean(c.socialMedias[i].customLabel),
              ),
      ],
      notes: c.notes.isEmpty ? null : _clean(c.notes.first.note),
      labelIds: {for (final g in c.groups) EntityId(g.id)},
      starred: c.isStarred,
      createdAt: now,
      updatedAt: now,
    );
  }

  // ------------------------------------------------------------- écriture

  /// Reporte la fiche du domaine sur [target].
  ///
  /// Les listes sont **remplacées** et non fusionnées : `updateContact` écrase
  /// les propriétés de la fiche, et le formulaire d'édition en est l'image
  /// complète — y ajouter l'existant dupliquerait chaque ligne à chaque
  /// enregistrement.
  fc.Contact _toNative(Contact contact, fc.Contact target) {
    target
      ..name = (fc.Name(
        first: contact.name.first ?? '',
        last: contact.name.last ?? '',
        middle: contact.name.middle ?? '',
        prefix: contact.name.prefix ?? '',
        suffix: contact.name.suffix ?? '',
        nickname: contact.name.nickname ?? '',
        firstPhonetic: contact.name.phoneticFirst ?? '',
        middlePhonetic: contact.name.phoneticMiddle ?? '',
        lastPhonetic: contact.name.phoneticLast ?? '',
      ))
      ..organizations = [
        if (contact.company != null || contact.jobTitle != null || contact.department != null)
          fc.Organization(
            company: contact.company ?? '',
            title: contact.jobTitle ?? '',
            department: contact.department ?? '',
          ),
      ]
      ..phones = [
        for (final p in contact.phones)
          fc.Phone(
            p.value,
            label: phoneLabelOf(p.type),
            customLabel: p.type == PhoneType.personnalise ? (p.customLabel ?? '') : '',
          ),
      ]
      ..emails = [
        for (final e in contact.emails)
          fc.Email(
            e.value,
            label: emailLabelOf(e.type),
            customLabel: e.type == EmailType.personnalise ? (e.customLabel ?? '') : '',
          ),
      ]
      ..addresses = [
        for (final a in contact.addresses)
          fc.Address(
            a.formatted,
            label: addressLabelOf(a.type),
            customLabel: a.type == AddressType.personnalise ? (a.customLabel ?? '') : '',
            street: a.street ?? '',
            pobox: a.poBox ?? '',
            city: a.city ?? '',
            state: a.region ?? '',
            postalCode: a.postcode ?? '',
            country: a.country ?? '',
          ),
      ]
      ..websites = [
        for (final w in contact.websites)
          fc.Website(
            w.value,
            label: websiteLabelOf(w.type),
            customLabel: w.type == WebsiteType.personnalise ? (w.customLabel ?? '') : '',
          ),
      ]
      ..events = [
        for (final e in contact.events)
          fc.Event(
            year: e.year,
            month: e.month,
            day: e.day,
            label: eventLabelOf(e.type),
            customLabel: e.type == EventType.personnalise ? (e.customLabel ?? '') : '',
          ),
      ]
      ..socialMedias = [
        for (final c in contact.chats)
          fc.SocialMedia(
            c.value,
            label: chatLabelOf(c.type),
            customLabel: c.type == ChatType.personnalise ? (c.customLabel ?? '') : '',
          ),
        for (final r in contact.relations)
          fc.SocialMedia(
            r.value,
            label: fc.SocialMediaLabel.custom,
            customLabel: '$relationLabelPrefix${r.label}',
          ),
      ]
      ..notes = [if (contact.notes != null) fc.Note(contact.notes!)]
      ..groups = [for (final id in contact.labelIds) fc.Group(id.value, '')]
      ..isStarred = contact.starred;

    if (contact.photo != null) target.photo = contact.photo;
    return target;
  }

  static String? _clean(String? value) =>
      value == null || value.trim().isEmpty ? null : value.trim();
}
