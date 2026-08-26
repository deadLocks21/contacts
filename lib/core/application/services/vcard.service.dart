import 'package:contacts/core/domain/exceptions/contact_exception.dart';
import 'package:contacts/core/domain/model/contact.dart';
import 'package:contacts/core/domain/model/contact_event.dart';
import 'package:contacts/core/domain/model/contact_label.dart';
import 'package:contacts/core/domain/model/contact_name.dart';
import 'package:contacts/core/domain/model/email_address.dart';
import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/core/domain/model/phone_number.dart';
import 'package:contacts/core/domain/model/postal_address.dart';
import 'package:contacts/core/domain/model/uuid_value.dart';
import 'package:contacts/core/domain/model/website.dart';

/// Contact importé et les noms d'étiquettes qu'il portait (`CATEGORIES`), que
/// l'appelant devra rapprocher des étiquettes existantes.
typedef ImportedContact = ({Contact contact, List<String> labelNames});

/// Lecture et écriture du format **vCard 3.0** — celui qu'exporte Google
/// Contacts, et le seul que tous les carnets d'adresses savent relire.
///
/// Les libellés personnalisés voyagent en `item<n>.X-ABLabel`, la convention
/// (Apple, reprise par Google) qui permet d'attacher un intitulé libre à une
/// ligne : sans elle, « Maison de campagne » redeviendrait « Autre » à
/// l'import.
abstract final class VCard {
  static const _crlf = '\r\n';

  // ---------------------------------------------------------------- export

  static String export(List<Contact> contacts, {List<ContactLabel> labels = const []}) =>
      contacts.map((c) => exportOne(c, labels: labels)).join();

  static String exportOne(Contact contact, {List<ContactLabel> labels = const []}) {
    final out = <String>['BEGIN:VCARD', 'VERSION:3.0'];
    var item = 0;

    /// Écrit une propriété, précédée de son `X-ABLabel` quand le libellé est
    /// personnalisé.
    void write(String name, String value, {List<String> params = const [], String? customLabel}) {
      if (customLabel == null) {
        out.add('$name${params.map((p) => ';$p').join()}:$value');
        return;
      }
      item++;
      final prefix = 'item$item';
      out.add('$prefix.$name${params.map((p) => ';$p').join()}:$value');
      out.add('$prefix.X-ABLabel:${_escape(customLabel)}');
    }

    final n = contact.name;
    out.add(
      'N:${[n.last, n.first, n.middle, n.prefix, n.suffix].map((p) => _escape(p ?? '')).join(';')}',
    );
    final fn = contact.displayName(NameFormat.prenomNom);
    if (fn.isNotEmpty) out.add('FN:${_escape(fn)}');
    if (n.nickname != null) out.add('NICKNAME:${_escape(n.nickname!)}');
    if (n.phoneticFirst != null) out.add('X-PHONETIC-FIRST-NAME:${_escape(n.phoneticFirst!)}');
    if (n.phoneticLast != null) out.add('X-PHONETIC-LAST-NAME:${_escape(n.phoneticLast!)}');

    if (contact.company != null || contact.department != null) {
      out.add('ORG:${_escape(contact.company ?? '')};${_escape(contact.department ?? '')}');
    }
    if (contact.jobTitle != null) out.add('TITLE:${_escape(contact.jobTitle!)}');

    for (final p in contact.phones) {
      write(
        'TEL',
        _escape(p.value),
        params: ['TYPE=${_phoneToWire(p.type)}'],
        customLabel: p.type == PhoneType.personnalise ? p.customLabel : null,
      );
    }
    for (final e in contact.emails) {
      write(
        'EMAIL',
        _escape(e.value),
        params: ['TYPE=${_emailToWire(e.type)}'],
        customLabel: e.type == EmailType.personnalise ? e.customLabel : null,
      );
    }
    for (final a in contact.addresses) {
      final parts = [
        a.poBox,
        '',
        a.street,
        a.city,
        a.region,
        a.postcode,
        a.country,
      ].map((p) => _escape(p ?? '')).join(';');
      write(
        'ADR',
        parts,
        params: ['TYPE=${_addressToWire(a.type)}'],
        customLabel: a.type == AddressType.personnalise ? a.customLabel : null,
      );
    }
    for (final w in contact.websites) {
      write(
        'URL',
        _escape(w.value),
        customLabel: w.type == WebsiteType.personnalise ? w.customLabel : null,
      );
    }
    for (final e in contact.events) {
      final date = e.year == null
          ? '--${_pad(e.month)}-${_pad(e.day)}'
          : '${e.year}-${_pad(e.month)}-${_pad(e.day)}';
      if (e.isBirthday) {
        out.add('BDAY:$date');
      } else {
        write('X-ABDATE', date, customLabel: e.label);
      }
    }
    for (final r in contact.relations) {
      write('X-ABRELATEDNAMES', _escape(r.value), customLabel: r.label);
    }
    for (final c in contact.chats) {
      out.add('X-${c.type.name.toUpperCase()}:${_escape(c.value)}');
    }
    if (contact.notes != null) out.add('NOTE:${_escape(contact.notes!)}');

    final names = [
      for (final l in labels)
        if (contact.labelIds.contains(l.id)) l.name,
    ];
    if (names.isNotEmpty) out.add('CATEGORIES:${names.map(_escape).join(',')}');
    if (contact.starred) out.add('X-GOOGLE-STARRED:true');

    out.add('END:VCARD');
    return '${out.map(_fold).join(_crlf)}$_crlf';
  }

  // ---------------------------------------------------------------- import

  static List<ImportedContact> parse(String source, {DateTime? now}) {
    final at = now ?? DateTime.now();
    final lines = _unfold(source);
    if (!lines.any((l) => l.toUpperCase().startsWith('BEGIN:VCARD'))) {
      throw const VCardParseException('Aucune fiche vCard trouvée dans le fichier');
    }

    final results = <ImportedContact>[];
    List<String>? current;
    for (final line in lines) {
      final upper = line.toUpperCase();
      if (upper.startsWith('BEGIN:VCARD')) {
        current = [];
      } else if (upper.startsWith('END:VCARD')) {
        if (current != null) results.add(_parseOne(current, at));
        current = null;
      } else {
        current?.add(line);
      }
    }
    if (results.isEmpty) throw const VCardParseException('Fichier vCard vide');
    return results;
  }

  static ImportedContact _parseOne(List<String> lines, DateTime at) {
    var name = ContactName.empty;
    String? company, department, jobTitle, notes, fullName;
    final phones = <PhoneNumber>[];
    final emails = <EmailAddress>[];
    final addresses = <PostalAddress>[];
    final websites = <Website>[];
    final events = <ContactEvent>[];
    final labelNames = <String>[];
    var starred = false;

    // Libellés personnalisés : `item1.X-ABLabel` s'applique à la ligne
    // `item1.TEL` — on collecte les deux avant de rapprocher.
    final customLabels = <String, String>{};
    final itemized = <String, ({String property, List<String> params, String value})>{};

    for (final line in lines) {
      final parsed = _parseLine(line);
      if (parsed == null) continue;
      var (property: property, params: params, value: value) = parsed;

      String? itemKey;
      final dot = property.indexOf('.');
      if (dot > 0) {
        itemKey = property.substring(0, dot);
        property = property.substring(dot + 1);
      }
      final upper = property.toUpperCase();

      if (upper == 'X-ABLABEL') {
        if (itemKey != null) customLabels[itemKey] = value;
        continue;
      }
      if (itemKey != null) {
        itemized[itemKey] = (property: upper, params: params, value: value);
        continue;
      }
      _apply(
        upper,
        params,
        value,
        name: () => name,
        setName: (n) => name = n,
        phones: phones,
        emails: emails,
        addresses: addresses,
        websites: websites,
        events: events,
        labelNames: labelNames,
        setCompany: (v) => company = v,
        setDepartment: (v) => department = v,
        setJobTitle: (v) => jobTitle = v,
        setNotes: (v) => notes = v,
        setFullName: (v) => fullName = v,
        setStarred: (v) => starred = v,
      );
    }

    for (final entry in itemized.entries) {
      final custom = customLabels[entry.key];
      _apply(
        entry.value.property,
        entry.value.params,
        entry.value.value,
        customLabel: custom,
        name: () => name,
        setName: (n) => name = n,
        phones: phones,
        emails: emails,
        addresses: addresses,
        websites: websites,
        events: events,
        labelNames: labelNames,
        setCompany: (v) => company = v,
        setDepartment: (v) => department = v,
        setJobTitle: (v) => jobTitle = v,
        setNotes: (v) => notes = v,
        setFullName: (v) => fullName = v,
        setStarred: (v) => starred = v,
      );
    }

    // `FN` seul (fiche sans `N`) : on le coupe en prénom + nom pour que le
    // contact reste éditable champ par champ.
    if (name.isEmpty && fullName != null && fullName!.trim().isNotEmpty) {
      final parts = fullName!.trim().split(RegExp(r'\s+'));
      name = parts.length == 1
          ? ContactName(first: parts.first)
          : ContactName(first: parts.first, last: parts.sublist(1).join(' '));
    }

    return (
      contact: Contact(
        id: UuidValue.generate(),
        name: name,
        company: company,
        department: department,
        jobTitle: jobTitle,
        phones: phones,
        emails: emails,
        addresses: addresses,
        websites: websites,
        events: events,
        notes: notes,
        starred: starred,
        createdAt: at,
        updatedAt: at,
      ),
      labelNames: labelNames,
    );
  }

  static void _apply(
    String property,
    List<String> params,
    String value, {
    String? customLabel,
    required ContactName Function() name,
    required void Function(ContactName) setName,
    required List<PhoneNumber> phones,
    required List<EmailAddress> emails,
    required List<PostalAddress> addresses,
    required List<Website> websites,
    required List<ContactEvent> events,
    required List<String> labelNames,
    required void Function(String) setCompany,
    required void Function(String) setDepartment,
    required void Function(String) setJobTitle,
    required void Function(String) setNotes,
    required void Function(String) setFullName,
    required void Function(bool) setStarred,
  }) {
    final types = _typesOf(params);
    switch (property) {
      case 'N':
        final p = value.split(';').map(_unescape).toList();
        String? at(int i) => i < p.length && p[i].trim().isNotEmpty ? p[i].trim() : null;
        setName(
          name().copyWith(last: at(0), first: at(1), middle: at(2), prefix: at(3), suffix: at(4)),
        );
      case 'FN':
        setFullName(_unescape(value));
      case 'NICKNAME':
        setName(name().copyWith(nickname: _unescape(value)));
      case 'X-PHONETIC-FIRST-NAME':
        setName(name().copyWith(phoneticFirst: _unescape(value)));
      case 'X-PHONETIC-LAST-NAME':
        setName(name().copyWith(phoneticLast: _unescape(value)));
      case 'ORG':
        final parts = value.split(';').map(_unescape).toList();
        if (parts.isNotEmpty && parts[0].trim().isNotEmpty) setCompany(parts[0].trim());
        if (parts.length > 1 && parts[1].trim().isNotEmpty) setDepartment(parts[1].trim());
      case 'TITLE':
        setJobTitle(_unescape(value));
      case 'TEL':
        if (_unescape(value).trim().isEmpty) return;
        phones.add(
          PhoneNumber(
            id: UuidValue.generate(),
            value: _unescape(value).trim(),
            type: customLabel != null ? PhoneType.personnalise : _phoneFromWire(types),
            customLabel: customLabel,
          ),
        );
      case 'EMAIL':
        if (_unescape(value).trim().isEmpty) return;
        emails.add(
          EmailAddress(
            id: UuidValue.generate(),
            value: _unescape(value).trim(),
            type: customLabel != null ? EmailType.personnalise : _emailFromWire(types),
            customLabel: customLabel,
          ),
        );
      case 'ADR':
        final p = value.split(';').map(_unescape).toList();
        String? at(int i) => i < p.length && p[i].trim().isNotEmpty ? p[i].trim() : null;
        final address = PostalAddress(
          id: UuidValue.generate(),
          poBox: at(0),
          street: at(2),
          city: at(3),
          region: at(4),
          postcode: at(5),
          country: at(6),
          type: customLabel != null ? AddressType.personnalise : _addressFromWire(types),
          customLabel: customLabel,
        );
        if (!address.isEmpty) addresses.add(address);
      case 'URL':
        if (_unescape(value).trim().isEmpty) return;
        websites.add(
          Website(
            id: UuidValue.generate(),
            value: _unescape(value).trim(),
            type: customLabel != null ? WebsiteType.personnalise : WebsiteType.profil,
            customLabel: customLabel,
          ),
        );
      case 'BDAY':
        final event = _parseDate(value, EventType.anniversaire, null);
        if (event != null) events.add(event);
      case 'X-ABDATE':
        final event = _parseDate(value, EventType.personnalise, customLabel);
        if (event != null) events.add(event);
      case 'NOTE':
        setNotes(_unescape(value));
      case 'CATEGORIES':
        labelNames.addAll(
          value.split(',').map(_unescape).map((c) => c.trim()).where((c) => c.isNotEmpty),
        );
      case 'X-GOOGLE-STARRED':
        setStarred(value.trim().toLowerCase() == 'true');
    }
  }

  /// `1990-02-14`, `19900214` ou `--02-14` (date sans année).
  static ContactEvent? _parseDate(String raw, EventType type, String? customLabel) {
    final value = raw.trim();
    final withYear = RegExp(r'^(\d{4})-?(\d{2})-?(\d{2})$').firstMatch(value);
    if (withYear != null) {
      return ContactEvent(
        id: UuidValue.generate(),
        year: int.parse(withYear.group(1)!),
        month: int.parse(withYear.group(2)!),
        day: int.parse(withYear.group(3)!),
        type: type,
        customLabel: customLabel,
      );
    }
    final noYear = RegExp(r'^--(\d{2})-?(\d{2})$').firstMatch(value);
    if (noYear != null) {
      return ContactEvent(
        id: UuidValue.generate(),
        month: int.parse(noYear.group(1)!),
        day: int.parse(noYear.group(2)!),
        type: type,
        customLabel: customLabel,
      );
    }
    return null;
  }

  // ------------------------------------------------------------- plomberie

  /// `item1.TEL;TYPE=CELL:+336…` → propriété, paramètres, valeur.
  static ({String property, List<String> params, String value})? _parseLine(String line) {
    final colon = _unquotedColon(line);
    if (colon < 0) return null;
    final head = line.substring(0, colon);
    final value = line.substring(colon + 1);
    final parts = head.split(';');
    return (property: parts.first, params: parts.skip(1).toList(), value: value);
  }

  /// Position du « : » séparateur — celui hors guillemets, un paramètre pouvant
  /// contenir une valeur entre quotes (`TYPE="a:b"`).
  static int _unquotedColon(String line) {
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (c == '"') inQuotes = !inQuotes;
      if (c == ':' && !inQuotes) return i;
    }
    return -1;
  }

  static List<String> _typesOf(List<String> params) {
    final types = <String>[];
    for (final p in params) {
      final eq = p.indexOf('=');
      if (eq < 0) {
        types.add(p.toUpperCase()); // vCard 2.1 : `TEL;CELL:`
      } else if (p.substring(0, eq).toUpperCase() == 'TYPE') {
        types.addAll(
          p.substring(eq + 1).replaceAll('"', '').split(',').map((t) => t.toUpperCase()),
        );
      }
    }
    return types;
  }

  /// Déplie les lignes de continuation (RFC 2425 : une ligne suivante qui
  /// commence par une espace ou une tabulation prolonge la précédente).
  static List<String> _unfold(String source) {
    final raw = source.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
    final out = <String>[];
    for (final line in raw) {
      if (line.isEmpty) continue;
      if ((line.startsWith(' ') || line.startsWith('\t')) && out.isNotEmpty) {
        out[out.length - 1] += line.substring(1);
      } else {
        out.add(line);
      }
    }
    return out;
  }

  /// Replie à 75 octets, comme le veut la spécification.
  static String _fold(String line) {
    if (line.length <= 75) return line;
    final buffer = StringBuffer(line.substring(0, 75));
    var rest = line.substring(75);
    while (rest.isNotEmpty) {
      final take = rest.length > 74 ? 74 : rest.length;
      buffer.write('$_crlf ${rest.substring(0, take)}');
      rest = rest.substring(take);
    }
    return buffer.toString();
  }

  static String _escape(String value) => value
      .replaceAll('\\', '\\\\')
      .replaceAll(';', '\\;')
      .replaceAll(',', '\\,')
      .replaceAll('\n', '\\n');

  static String _unescape(String value) {
    final out = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      if (value[i] == '\\' && i + 1 < value.length) {
        final next = value[++i];
        out.write(switch (next) {
          'n' || 'N' => '\n',
          _ => next,
        });
      } else {
        out.write(value[i]);
      }
    }
    return out.toString();
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');

  static String _phoneToWire(PhoneType type) => switch (type) {
    PhoneType.mobile => 'CELL',
    PhoneType.domicile => 'HOME',
    PhoneType.professionnel => 'WORK',
    PhoneType.faxProfessionnel => 'WORK,FAX',
    PhoneType.faxPersonnel => 'HOME,FAX',
    PhoneType.principal => 'MAIN',
    PhoneType.bipeur => 'PAGER',
    PhoneType.voiture => 'CAR',
    PhoneType.mobileProfessionnel => 'WORK,CELL',
    PhoneType.bipeurProfessionnel => 'WORK,PAGER',
    PhoneType.isdn => 'ISDN',
    PhoneType.telex => 'TLX',
    PhoneType.ttyAts => 'TTY',
    _ => 'OTHER',
  };

  static PhoneType _phoneFromWire(List<String> types) {
    final has = types.contains;
    if (has('FAX')) return has('WORK') ? PhoneType.faxProfessionnel : PhoneType.faxPersonnel;
    if (has('PAGER')) return has('WORK') ? PhoneType.bipeurProfessionnel : PhoneType.bipeur;
    if (has('CELL')) return has('WORK') ? PhoneType.mobileProfessionnel : PhoneType.mobile;
    if (has('MAIN')) return PhoneType.principal;
    if (has('CAR')) return PhoneType.voiture;
    if (has('ISDN')) return PhoneType.isdn;
    if (has('TLX')) return PhoneType.telex;
    if (has('TTY')) return PhoneType.ttyAts;
    if (has('WORK')) return PhoneType.professionnel;
    if (has('HOME')) return PhoneType.domicile;
    return PhoneType.mobile;
  }

  static String _emailToWire(EmailType type) => switch (type) {
    EmailType.domicile => 'HOME',
    EmailType.professionnel => 'WORK',
    EmailType.mobile => 'CELL',
    _ => 'OTHER',
  };

  static EmailType _emailFromWire(List<String> types) {
    if (types.contains('WORK')) return EmailType.professionnel;
    if (types.contains('CELL')) return EmailType.mobile;
    if (types.contains('HOME')) return EmailType.domicile;
    return EmailType.domicile;
  }

  static String _addressToWire(AddressType type) => switch (type) {
    AddressType.domicile => 'HOME',
    AddressType.professionnel => 'WORK',
    _ => 'OTHER',
  };

  static AddressType _addressFromWire(List<String> types) {
    if (types.contains('WORK')) return AddressType.professionnel;
    if (types.contains('HOME')) return AddressType.domicile;
    return AddressType.autre;
  }
}
