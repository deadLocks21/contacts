import 'package:contacts/core/application/services/text_normalizer.service.dart';
import 'package:contacts/core/domain/model/contact.dart';
import 'package:contacts/core/domain/model/enums.dart';

/// Recherche dans le carnet.
///
/// Tous les mots de la requête doivent être trouvés (ET), chacun pouvant l'être
/// dans n'importe quel champ : « dupont bnp » retrouve Marie Dupont de la BNP.
/// Les résultats sont classés par pertinence — un nom qui *commence* par la
/// requête passe devant une société qui la contient au milieu.
abstract final class ContactSearch {
  static List<Contact> run(
    List<Contact> contacts,
    String query, {
    required NameFormat nameFormat,
  }) {
    final tokens = TextNormalizer.tokenize(query);
    if (tokens.isEmpty) return const [];

    final digits = TextNormalizer.digitsOnly(query);
    final scored = <(int, Contact)>[];
    for (final contact in contacts) {
      final score = _score(contact, tokens, digits, nameFormat);
      if (score > 0) scored.add((score, contact));
    }

    scored.sort((a, b) {
      final byScore = b.$1.compareTo(a.$1);
      if (byScore != 0) return byScore;
      final an = TextNormalizer.normalize(a.$2.displayName(nameFormat));
      final bn = TextNormalizer.normalize(b.$2.displayName(nameFormat));
      final byName = an.compareTo(bn);
      return byName != 0 ? byName : a.$2.id.value.compareTo(b.$2.id.value);
    });
    return [for (final s in scored) s.$2];
  }

  /// Score de pertinence, ou 0 si la fiche ne correspond pas.
  static int _score(Contact contact, List<String> tokens, String digits, NameFormat nameFormat) {
    final name = TextNormalizer.normalize(contact.displayName(nameFormat));
    final nameWords = name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final haystacks = _haystacks(contact);
    // Un numéro tapé en chiffres est comparé aux chiffres des numéros stockés :
    // « 0612 » doit retrouver un « +33 6 12 … ».
    final phoneDigits = [for (final p in contact.phones) p.digits];

    var total = 0;
    for (final token in tokens) {
      var best = 0;
      if (name.startsWith(token)) {
        best = 100;
      } else if (nameWords.any((w) => w.startsWith(token))) {
        best = 80;
      } else if (name.contains(token)) {
        best = 50;
      }
      if (best < 40 && haystacks.any((h) => h.startsWith(token))) best = 40;
      if (best < 20 && haystacks.any((h) => h.contains(token))) best = 20;
      if (best == 0 && digits.length >= 2 && phoneDigits.any((d) => d.contains(digits))) {
        best = 30;
      }
      if (best == 0) return 0; // un mot non trouvé écarte la fiche
      total += best;
    }
    // Les favoris remontent à pertinence égale.
    return contact.starred ? total + 5 : total;
  }

  /// Tous les textes d'une fiche dans lesquels chercher, normalisés.
  static List<String> _haystacks(Contact contact) => [
    for (final v in [
      contact.name.fullName,
      contact.name.nickname,
      contact.name.phoneticFirst,
      contact.name.phoneticLast,
      contact.company,
      contact.jobTitle,
      contact.department,
      contact.notes,
      for (final p in contact.phones) p.value,
      for (final e in contact.emails) e.value,
      for (final a in contact.addresses) a.formatted,
      for (final w in contact.websites) w.value,
      for (final r in contact.relations) r.value,
      for (final c in contact.chats) c.value,
    ])
      if (v != null && v.trim().isNotEmpty) TextNormalizer.normalize(v),
  ];
}
