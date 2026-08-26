import 'package:contacts/core/application/dtos/contact_detail.dto.dart';
import 'package:contacts/core/application/dtos/contact_field.dto.dart';
import 'package:contacts/core/application/dtos/contact_summary.dto.dart';
import 'package:contacts/core/application/dtos/label.dto.dart';
import 'package:contacts/core/application/services/date_label.service.dart';
import 'package:contacts/core/application/services/phone_format.service.dart';
import 'package:contacts/core/application/services/text_normalizer.service.dart';
import 'package:contacts/core/domain/model/contact.dart';
import 'package:contacts/core/domain/model/contact_label.dart';
import 'package:contacts/core/domain/model/enums.dart';

/// Traduit les entités du domaine en DTOs prêts à afficher. C'est ici que
/// s'appliquent la mise en forme (numéros, dates) et les réglages d'affichage
/// (tri, format de nom) — l'UI n'a plus qu'à peindre.
abstract final class ContactMapper {
  static ContactSummaryDto summary(
    Contact contact, {
    required NameFormat nameFormat,
    required ContactSortOrder sortOrder,
  }) {
    final sortSource = contact.name.sortKey(sortOrder);
    // Un contact sans nom se range sous sa société, à défaut sous son premier
    // e-mail — sans quoi il atterrirait sous « # » alors qu'il a un libellé.
    final effective = sortSource.isNotEmpty ? sortSource : contact.displayName(nameFormat);
    return ContactSummaryDto.fromDomain(
      contact,
      nameFormat: nameFormat,
      sectionKey: TextNormalizer.sectionKey(effective),
      sortKey: TextNormalizer.normalize(effective),
    );
  }

  static ContactDetailDto detail(
    Contact contact, {
    required NameFormat nameFormat,
    List<ContactLabel> allLabels = const [],
  }) {
    final nickname = contact.name.nickname?.trim();
    return ContactDetailDto(
      id: contact.id.value,
      displayName: contact.displayName(nameFormat),
      nickname: (nickname?.isNotEmpty ?? false) ? nickname : null,
      initials: contact.initials,
      photoPath: contact.photoPath,
      starred: contact.starred,
      subtitle: contact.subtitle,
      phones: [
        for (final p in contact.phones)
          ContactFieldDto(
            id: p.id.value,
            label: p.label,
            value: PhoneFormat.display(p.value),
            rawValue: PhoneFormat.dialable(p.value),
          ),
      ],
      emails: [
        for (final e in contact.emails)
          ContactFieldDto(id: e.id.value, label: e.label, value: e.value, rawValue: e.value),
      ],
      addresses: [
        for (final a in contact.addresses)
          ContactFieldDto(
            id: a.id.value,
            label: a.label,
            value: a.multiline,
            rawValue: a.formatted,
          ),
      ],
      websites: [
        for (final w in contact.websites)
          ContactFieldDto(
            id: w.id.value,
            label: w.label,
            value: w.value,
            rawValue: w.uri.toString(),
          ),
      ],
      events: [
        for (final e in contact.events)
          ContactFieldDto(
            id: e.id.value,
            label: e.label,
            value: DateLabel.eventDate(e.day, e.month, e.year),
            rawValue: DateLabel.eventDate(e.day, e.month, e.year),
          ),
      ],
      relations: [
        for (final r in contact.relations)
          ContactFieldDto(id: r.id.value, label: r.label, value: r.value, rawValue: r.value),
      ],
      chats: [
        for (final c in contact.chats)
          ContactFieldDto(id: c.id.value, label: c.label, value: c.value, rawValue: c.value),
      ],
      notes: contact.notes,
      labels: [
        for (final l in allLabels)
          if (contact.labelIds.contains(l.id)) LabelDto.fromDomain(l),
      ],
      sendToVoicemail: contact.sendToVoicemail,
      customRingtone: contact.customRingtone,
      isTrashed: contact.isTrashed,
    );
  }
}
