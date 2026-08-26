import 'package:contacts/core/application/services/text_normalizer.service.dart';
import 'package:contacts/core/domain/model/chat_address.dart';
import 'package:contacts/core/domain/model/contact.dart';
import 'package:contacts/core/domain/model/contact_event.dart';
import 'package:contacts/core/domain/model/contact_name.dart';
import 'package:contacts/core/domain/model/email_address.dart';
import 'package:contacts/core/domain/model/phone_number.dart';
import 'package:contacts/core/domain/model/postal_address.dart';
import 'package:contacts/core/domain/model/relation.dart';
import 'package:contacts/core/domain/model/entity_id.dart';
import 'package:contacts/core/domain/model/website.dart';

/// Fusionne plusieurs fiches en une seule.
///
/// Principe : **ne rien perdre**. La fiche retenue est la plus ancienne (son
/// identifiant survit, les autres partent) ; chaque champ absent d'elle est
/// complété par la première autre fiche qui le renseigne, et les listes sont
/// concaténées sans doublon.
abstract final class ContactMerge {
  static Contact merge(List<Contact> contacts, {DateTime? now}) {
    assert(contacts.isNotEmpty, 'nothing to merge');
    final ordered = [...contacts]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final primary = ordered.first;

    String? firstOf(String? Function(Contact) pick) {
      for (final c in ordered) {
        final v = pick(c)?.trim();
        if (v != null && v.isNotEmpty) return v;
      }
      return null;
    }

    final name = ContactName(
      prefix: firstOf((c) => c.name.prefix),
      first: firstOf((c) => c.name.first),
      middle: firstOf((c) => c.name.middle),
      last: firstOf((c) => c.name.last),
      suffix: firstOf((c) => c.name.suffix),
      phoneticFirst: firstOf((c) => c.name.phoneticFirst),
      phoneticMiddle: firstOf((c) => c.name.phoneticMiddle),
      phoneticLast: firstOf((c) => c.name.phoneticLast),
      nickname: firstOf((c) => c.name.nickname),
    );

    // Les notes des différentes fiches sont conservées l'une sous l'autre :
    // c'est du texte libre, rien ne dit laquelle prime.
    final notes = <String>[];
    for (final c in ordered) {
      final n = c.notes?.trim();
      if (n != null && n.isNotEmpty && !notes.contains(n)) notes.add(n);
    }

    return Contact(
      id: primary.id,
      name: name,
      company: firstOf((c) => c.company),
      jobTitle: firstOf((c) => c.jobTitle),
      department: firstOf((c) => c.department),
      photoPath: firstOf((c) => c.photoPath),
      phones: _dedupe([
        for (final c in ordered) ...c.phones,
      ], (PhoneNumber p) => p.digits.isEmpty ? p.value : p.digits),
      emails: _dedupe([
        for (final c in ordered) ...c.emails,
      ], (EmailAddress e) => TextNormalizer.normalize(e.value)),
      addresses: _dedupe([
        for (final c in ordered) ...c.addresses,
      ], (PostalAddress a) => TextNormalizer.normalize(a.formatted)),
      websites: _dedupe([
        for (final c in ordered) ...c.websites,
      ], (Website w) => TextNormalizer.normalize(w.value)),
      events: _dedupe([
        for (final c in ordered) ...c.events,
      ], (ContactEvent e) => '${e.type.wire}:${e.year}-${e.month}-${e.day}'),
      relations: _dedupe([
        for (final c in ordered) ...c.relations,
      ], (Relation r) => '${r.type.wire}:${TextNormalizer.normalize(r.value)}'),
      chats: _dedupe([
        for (final c in ordered) ...c.chats,
      ], (ChatAddress c) => '${c.type.wire}:${TextNormalizer.normalize(c.value)}'),
      notes: notes.isEmpty ? null : notes.join('\n'),
      labelIds: {for (final c in ordered) ...c.labelIds},
      starred: ordered.any((c) => c.starred),
      customRingtone: firstOf((c) => c.customRingtone),
      sendToVoicemail: ordered.any((c) => c.sendToVoicemail),
      createdAt: primary.createdAt,
      updatedAt: now ?? DateTime.now(),
    );
  }

  /// Identifiants des fiches absorbées, à supprimer après la fusion.
  static List<EntityId> absorbedIds(List<Contact> contacts) {
    final ordered = [...contacts]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return [for (final c in ordered.skip(1)) c.id];
  }

  static List<T> _dedupe<T>(List<T> items, String Function(T) keyOf) {
    final seen = <String>{};
    final out = <T>[];
    for (final item in items) {
      if (seen.add(keyOf(item))) out.add(item);
    }
    return out;
  }
}
