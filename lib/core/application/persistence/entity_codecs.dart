import 'package:contacts/core/application/persistence/record_codec.dart';
import 'package:contacts/core/domain/model/chat_address.dart';
import 'package:contacts/core/domain/model/contact.dart';
import 'package:contacts/core/domain/model/contact_event.dart';
import 'package:contacts/core/domain/model/contact_label.dart';
import 'package:contacts/core/domain/model/contact_name.dart';
import 'package:contacts/core/domain/model/email_address.dart';
import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/core/domain/model/phone_number.dart';
import 'package:contacts/core/domain/model/postal_address.dart';
import 'package:contacts/core/domain/model/relation.dart';
import 'package:contacts/core/domain/model/uuid_value.dart';
import 'package:contacts/core/domain/model/website.dart';

/// Codecs JSON des entités persistées. Dates en **ISO-8601 UTC**, enums par
/// leur `wire` : le format doit survivre à un renommage de libellé.
const contactCodec = _ContactCodec();
const labelCodec = _LabelCodec();

String? _str(Object? v) => v == null ? null : v as String;
DateTime _date(Object? v) => DateTime.parse(v! as String).toLocal();
DateTime? _dateOrNull(Object? v) => v == null ? null : DateTime.parse(v as String).toLocal();
List<Map<String, Object?>> _list(Object? v) => [
  for (final e in (v as List? ?? const [])) (e as Map).cast<String, Object?>(),
];

class _ContactCodec implements RecordCodec<Contact> {
  const _ContactCodec();

  @override
  String get resource => 'contacts';

  @override
  String idOf(Contact e) => e.id.value;

  @override
  DateTime updatedAtOf(Contact e) => e.updatedAt;

  @override
  DateTime? deletedAtOf(Contact e) => e.deletedAt;

  @override
  Map<String, Object?> toJson(Contact c) => {
    'id': c.id.value,
    'name': {
      'prefix': c.name.prefix,
      'first': c.name.first,
      'middle': c.name.middle,
      'last': c.name.last,
      'suffix': c.name.suffix,
      'phonetic_first': c.name.phoneticFirst,
      'phonetic_middle': c.name.phoneticMiddle,
      'phonetic_last': c.name.phoneticLast,
      'nickname': c.name.nickname,
    },
    'company': c.company,
    'job_title': c.jobTitle,
    'department': c.department,
    'photo_path': c.photoPath,
    'phones': [
      for (final p in c.phones)
        {'id': p.id.value, 'value': p.value, 'type': p.type.wire, 'custom_label': p.customLabel},
    ],
    'emails': [
      for (final e in c.emails)
        {'id': e.id.value, 'value': e.value, 'type': e.type.wire, 'custom_label': e.customLabel},
    ],
    'addresses': [
      for (final a in c.addresses)
        {
          'id': a.id.value,
          'street': a.street,
          'city': a.city,
          'postcode': a.postcode,
          'region': a.region,
          'country': a.country,
          'po_box': a.poBox,
          'type': a.type.wire,
          'custom_label': a.customLabel,
        },
    ],
    'websites': [
      for (final w in c.websites)
        {'id': w.id.value, 'value': w.value, 'type': w.type.wire, 'custom_label': w.customLabel},
    ],
    'events': [
      for (final e in c.events)
        {
          'id': e.id.value,
          'year': e.year,
          'month': e.month,
          'day': e.day,
          'type': e.type.wire,
          'custom_label': e.customLabel,
        },
    ],
    'relations': [
      for (final r in c.relations)
        {'id': r.id.value, 'value': r.value, 'type': r.type.wire, 'custom_label': r.customLabel},
    ],
    'chats': [
      for (final ch in c.chats)
        {
          'id': ch.id.value,
          'value': ch.value,
          'type': ch.type.wire,
          'custom_label': ch.customLabel,
        },
    ],
    'notes': c.notes,
    'label_ids': [for (final l in c.labelIds) l.value],
    'starred': c.starred,
    'custom_ringtone': c.customRingtone,
    'send_to_voicemail': c.sendToVoicemail,
    'created_at': c.createdAt.toUtc().toIso8601String(),
    'updated_at': c.updatedAt.toUtc().toIso8601String(),
    'deleted_at': c.deletedAt?.toUtc().toIso8601String(),
  };

  @override
  Contact fromJson(Map<String, Object?> json) {
    final name = (json['name'] as Map? ?? const {}).cast<String, Object?>();
    return Contact(
      id: UuidValue.parse(json['id']! as String),
      name: ContactName(
        prefix: _str(name['prefix']),
        first: _str(name['first']),
        middle: _str(name['middle']),
        last: _str(name['last']),
        suffix: _str(name['suffix']),
        phoneticFirst: _str(name['phonetic_first']),
        phoneticMiddle: _str(name['phonetic_middle']),
        phoneticLast: _str(name['phonetic_last']),
        nickname: _str(name['nickname']),
      ),
      company: _str(json['company']),
      jobTitle: _str(json['job_title']),
      department: _str(json['department']),
      photoPath: _str(json['photo_path']),
      phones: [
        for (final p in _list(json['phones']))
          PhoneNumber(
            id: UuidValue.parse(p['id']! as String),
            value: p['value']! as String,
            type: PhoneType.fromWire(_str(p['type'])),
            customLabel: _str(p['custom_label']),
          ),
      ],
      emails: [
        for (final e in _list(json['emails']))
          EmailAddress(
            id: UuidValue.parse(e['id']! as String),
            value: e['value']! as String,
            type: EmailType.fromWire(_str(e['type'])),
            customLabel: _str(e['custom_label']),
          ),
      ],
      addresses: [
        for (final a in _list(json['addresses']))
          PostalAddress(
            id: UuidValue.parse(a['id']! as String),
            street: _str(a['street']),
            city: _str(a['city']),
            postcode: _str(a['postcode']),
            region: _str(a['region']),
            country: _str(a['country']),
            poBox: _str(a['po_box']),
            type: AddressType.fromWire(_str(a['type'])),
            customLabel: _str(a['custom_label']),
          ),
      ],
      websites: [
        for (final w in _list(json['websites']))
          Website(
            id: UuidValue.parse(w['id']! as String),
            value: w['value']! as String,
            type: WebsiteType.fromWire(_str(w['type'])),
            customLabel: _str(w['custom_label']),
          ),
      ],
      events: [
        for (final e in _list(json['events']))
          ContactEvent(
            id: UuidValue.parse(e['id']! as String),
            year: e['year'] as int?,
            month: e['month']! as int,
            day: e['day']! as int,
            type: EventType.fromWire(_str(e['type'])),
            customLabel: _str(e['custom_label']),
          ),
      ],
      relations: [
        for (final r in _list(json['relations']))
          Relation(
            id: UuidValue.parse(r['id']! as String),
            value: r['value']! as String,
            type: RelationType.fromWire(_str(r['type'])),
            customLabel: _str(r['custom_label']),
          ),
      ],
      chats: [
        for (final c in _list(json['chats']))
          ChatAddress(
            id: UuidValue.parse(c['id']! as String),
            value: c['value']! as String,
            type: ChatType.fromWire(_str(c['type'])),
            customLabel: _str(c['custom_label']),
          ),
      ],
      notes: _str(json['notes']),
      labelIds: {
        for (final l in (json['label_ids'] as List? ?? const [])) UuidValue.parse(l as String),
      },
      starred: json['starred'] as bool? ?? false,
      customRingtone: _str(json['custom_ringtone']),
      sendToVoicemail: json['send_to_voicemail'] as bool? ?? false,
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
      deletedAt: _dateOrNull(json['deleted_at']),
    );
  }
}

class _LabelCodec implements RecordCodec<ContactLabel> {
  const _LabelCodec();

  @override
  String get resource => 'labels';

  @override
  String idOf(ContactLabel e) => e.id.value;

  @override
  DateTime updatedAtOf(ContactLabel e) => e.updatedAt;

  @override
  DateTime? deletedAtOf(ContactLabel e) => null;

  @override
  Map<String, Object?> toJson(ContactLabel l) => {
    'id': l.id.value,
    'name': l.name,
    'created_at': l.createdAt.toUtc().toIso8601String(),
    'updated_at': l.updatedAt.toUtc().toIso8601String(),
  };

  @override
  ContactLabel fromJson(Map<String, Object?> json) => ContactLabel(
    id: UuidValue.parse(json['id']! as String),
    name: json['name']! as String,
    createdAt: _date(json['created_at']),
    updatedAt: _date(json['updated_at']),
  );
}
