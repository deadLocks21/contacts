import 'package:contacts/core/application/dtos/duplicate_group.dto.dart';
import 'package:contacts/core/application/services/text_normalizer.service.dart';
import 'package:contacts/core/domain/model/contact.dart';
import 'package:contacts/core/domain/model/enums.dart';

/// Repère les fiches qui décrivent vraisemblablement la même personne.
///
/// Trois critères, du plus sûr au moins sûr : même adresse e-mail, même
/// numéro de téléphone, même nom complet. Une paire n'est signalée qu'une
/// fois, par son critère le plus fort — sans quoi deux fiches identiques
/// apparaîtraient trois fois dans « Fusionner et corriger ».
abstract final class DuplicateDetection {
  static List<({String key, DuplicateReason reason, List<Contact> contacts})> find(
    List<Contact> contacts, {
    required NameFormat nameFormat,
  }) {
    final groups = <({String key, DuplicateReason reason, List<Contact> contacts})>[];
    // Fiches déjà groupées : une fiche n'appartient qu'à un seul groupe, le
    // premier (donc le plus sûr) qui la retient.
    final claimed = <String>{};

    void collect(DuplicateReason reason, Map<String, List<Contact>> buckets) {
      final keys = buckets.keys.toList()..sort();
      for (final key in keys) {
        final members = buckets[key]!.where((c) => !claimed.contains(c.id.value)).toList();
        if (members.length < 2) continue;
        for (final m in members) {
          claimed.add(m.id.value);
        }
        members.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        groups.add((key: '${reason.name}:$key', reason: reason, contacts: members));
      }
    }

    collect(DuplicateReason.email, _bucketBy(contacts, (c) => [
      for (final e in c.emails) TextNormalizer.normalize(e.value),
    ]));
    collect(DuplicateReason.telephone, _bucketBy(contacts, (c) => [
      // Les 9 derniers chiffres suffisent à rapprocher « 06 12 34 56 78 » et
      // « +33 6 12 34 56 78 », qui ne partagent ni préfixe ni longueur.
      for (final p in c.phones)
        if (p.digits.length >= 9) p.digits.substring(p.digits.length - 9),
    ]));
    collect(DuplicateReason.nom, _bucketBy(contacts, (c) {
      final name = TextNormalizer.normalize(c.displayName(nameFormat));
      return name.isEmpty ? const [] : [name];
    }));

    return groups;
  }

  static Map<String, List<Contact>> _bucketBy(
    List<Contact> contacts,
    List<String> Function(Contact) keysOf,
  ) {
    final buckets = <String, List<Contact>>{};
    for (final contact in contacts) {
      for (final key in keysOf(contact).where((k) => k.isNotEmpty).toSet()) {
        buckets.putIfAbsent(key, () => []).add(contact);
      }
    }
    return buckets;
  }
}
