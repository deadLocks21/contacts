import 'package:contacts/core/domain/model/enums.dart';

/// Nom structuré d'un contact — les neuf champs que Google Contacts expose
/// derrière la flèche « Plus » du bloc nom.
///
/// Aucun champ n'est obligatoire : un contact peut n'avoir qu'un e-mail ou
/// qu'une société. [displayName] retombe alors sur ce qu'il reste, et en
/// dernier recours sur une chaîne vide (l'UI affiche « (Sans nom) »).
class ContactName {
  final String? prefix;
  final String? first;
  final String? middle;
  final String? last;
  final String? suffix;
  final String? phoneticFirst;
  final String? phoneticMiddle;
  final String? phoneticLast;
  final String? nickname;

  const ContactName({
    this.prefix,
    this.first,
    this.middle,
    this.last,
    this.suffix,
    this.phoneticFirst,
    this.phoneticMiddle,
    this.phoneticLast,
    this.nickname,
  });

  static const empty = ContactName();

  bool get isEmpty => _parts.isEmpty && (nickname == null || nickname!.trim().isEmpty);

  List<String> get _parts => [
    prefix,
    first,
    middle,
    last,
    suffix,
  ].map((p) => p?.trim() ?? '').where((p) => p.isNotEmpty).toList();

  /// Nom complet dans l'ordre naturel : « Dr Jean-Paul Martin Jr. ».
  String get fullName => _parts.join(' ');

  /// Nom tel qu'affiché, selon le format choisi dans les réglages.
  /// `nomPrenom` donne « Martin, Jean-Paul » — le reste (préfixe, suffixe,
  /// second prénom) suit l'ordre naturel.
  String displayName(NameFormat format) {
    final f = first?.trim() ?? '';
    final l = last?.trim() ?? '';
    if (format == NameFormat.nomPrenom && f.isNotEmpty && l.isNotEmpty) {
      final middleParts = [middle, suffix].map((p) => p?.trim() ?? '').where((p) => p.isNotEmpty);
      return ['$l,', f, ...middleParts].join(' ');
    }
    if (fullName.isNotEmpty) return fullName;
    return nickname?.trim() ?? '';
  }

  /// Clé de tri : le prénom ou le nom de famille selon les réglages, avec bascule
  /// sur l'autre quand le champ demandé est vide (sans quoi tous les contacts
  /// mononymes se retrouveraient sous « # »).
  String sortKey(ContactSortOrder order) {
    final f = first?.trim() ?? '';
    final l = last?.trim() ?? '';
    final primary = order == ContactSortOrder.nom ? l : f;
    if (primary.isNotEmpty) return primary;
    final fallback = order == ContactSortOrder.nom ? f : l;
    if (fallback.isNotEmpty) return fallback;
    return nickname?.trim() ?? '';
  }

  /// Initiale(s) de l'avatar : une lettre, deux si prénom **et** nom sont
  /// connus — comme les pastilles colorées de Google Contacts.
  String get initials {
    final f = first?.trim() ?? '';
    final l = last?.trim() ?? '';
    if (f.isNotEmpty && l.isNotEmpty) return '${f[0]}${l[0]}'.toUpperCase();
    final single = [f, l, nickname?.trim() ?? ''].firstWhere((p) => p.isNotEmpty, orElse: () => '');
    return single.isEmpty ? '' : single[0].toUpperCase();
  }

  ContactName copyWith({
    String? prefix,
    String? first,
    String? middle,
    String? last,
    String? suffix,
    String? phoneticFirst,
    String? phoneticMiddle,
    String? phoneticLast,
    String? nickname,
  }) {
    return ContactName(
      prefix: prefix ?? this.prefix,
      first: first ?? this.first,
      middle: middle ?? this.middle,
      last: last ?? this.last,
      suffix: suffix ?? this.suffix,
      phoneticFirst: phoneticFirst ?? this.phoneticFirst,
      phoneticMiddle: phoneticMiddle ?? this.phoneticMiddle,
      phoneticLast: phoneticLast ?? this.phoneticLast,
      nickname: nickname ?? this.nickname,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactName &&
          runtimeType == other.runtimeType &&
          prefix == other.prefix &&
          first == other.first &&
          middle == other.middle &&
          last == other.last &&
          suffix == other.suffix &&
          phoneticFirst == other.phoneticFirst &&
          phoneticMiddle == other.phoneticMiddle &&
          phoneticLast == other.phoneticLast &&
          nickname == other.nickname;

  @override
  int get hashCode => Object.hash(
    prefix,
    first,
    middle,
    last,
    suffix,
    phoneticFirst,
    phoneticMiddle,
    phoneticLast,
    nickname,
  );
}
