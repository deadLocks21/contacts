// Types de champs d'un contact. Les listes reprennent, dans l'ordre, celles
// que Google Contacts propose dans ses sélecteurs de libellé.
//
// Chaque enum expose :
// - `wire` : forme stockée (stable, indépendante de l'affichage) ;
// - `fromWire` : relecture tolérante (valeur inconnue → « autre ») ;
// - `label` : libellé affiché, en français.
//
// La valeur `personnalise` signale que le libellé réel est porté par le champ
// `customLabel` de la donnée (cf. `LabeledField.label`).

/// Type d'un numéro de téléphone.
enum PhoneType {
  mobile,
  domicile,
  professionnel,
  faxProfessionnel,
  faxPersonnel,
  principal,
  bipeur,
  rappel,
  voiture,
  standardEntreprise,
  isdn,
  autreFax,
  radio,
  telex,
  ttyAts,
  mobileProfessionnel,
  bipeurProfessionnel,
  assistant,
  mms,
  autre,
  personnalise;

  String get wire => name;
  static PhoneType fromWire(String? w) =>
      PhoneType.values.where((e) => e.name == w).firstOrNull ?? PhoneType.autre;

  String get label => switch (this) {
    PhoneType.mobile => 'Mobile',
    PhoneType.domicile => 'Domicile',
    PhoneType.professionnel => 'Professionnel',
    PhoneType.faxProfessionnel => 'Fax professionnel',
    PhoneType.faxPersonnel => 'Fax personnel',
    PhoneType.principal => 'Principal',
    PhoneType.bipeur => 'Bipeur',
    PhoneType.rappel => 'Rappel',
    PhoneType.voiture => 'Voiture',
    PhoneType.standardEntreprise => 'Standard entreprise',
    PhoneType.isdn => 'RNIS',
    PhoneType.autreFax => 'Autre fax',
    PhoneType.radio => 'Radio',
    PhoneType.telex => 'Télex',
    PhoneType.ttyAts => 'TTY/ATS',
    PhoneType.mobileProfessionnel => 'Mobile professionnel',
    PhoneType.bipeurProfessionnel => 'Bipeur professionnel',
    PhoneType.assistant => 'Assistant',
    PhoneType.mms => 'MMS',
    PhoneType.autre => 'Autre',
    PhoneType.personnalise => 'Personnalisé',
  };
}

/// Type d'une adresse e-mail.
enum EmailType {
  domicile,
  professionnel,
  mobile,
  autre,
  personnalise;

  String get wire => name;
  static EmailType fromWire(String? w) =>
      EmailType.values.where((e) => e.name == w).firstOrNull ?? EmailType.autre;

  String get label => switch (this) {
    EmailType.domicile => 'Domicile',
    EmailType.professionnel => 'Professionnel',
    EmailType.mobile => 'Mobile',
    EmailType.autre => 'Autre',
    EmailType.personnalise => 'Personnalisé',
  };
}

/// Type d'une adresse postale.
enum AddressType {
  domicile,
  professionnel,
  autre,
  personnalise;

  String get wire => name;
  static AddressType fromWire(String? w) =>
      AddressType.values.where((e) => e.name == w).firstOrNull ?? AddressType.autre;

  String get label => switch (this) {
    AddressType.domicile => 'Domicile',
    AddressType.professionnel => 'Professionnel',
    AddressType.autre => 'Autre',
    AddressType.personnalise => 'Personnalisé',
  };
}

/// Type d'une date importante. `anniversaire` = date de naissance : c'est elle
/// que l'app met en avant (icône gâteau, rappels).
enum EventType {
  anniversaire,
  anniversaireDeMariage,
  autre,
  personnalise;

  String get wire => name;
  static EventType fromWire(String? w) =>
      EventType.values.where((e) => e.name == w).firstOrNull ?? EventType.autre;

  String get label => switch (this) {
    EventType.anniversaire => 'Anniversaire',
    EventType.anniversaireDeMariage => 'Anniversaire de mariage',
    EventType.autre => 'Autre',
    EventType.personnalise => 'Personnalisé',
  };
}

/// Type d'un site web.
enum WebsiteType {
  profil,
  blog,
  pageDAccueil,
  pagePrincipale,
  professionnel,
  ftp,
  autre,
  personnalise;

  String get wire => name;
  static WebsiteType fromWire(String? w) =>
      WebsiteType.values.where((e) => e.name == w).firstOrNull ?? WebsiteType.autre;

  String get label => switch (this) {
    WebsiteType.profil => 'Profil',
    WebsiteType.blog => 'Blog',
    WebsiteType.pageDAccueil => "Page d'accueil",
    WebsiteType.pagePrincipale => 'Page principale',
    WebsiteType.professionnel => 'Professionnel',
    WebsiteType.ftp => 'FTP',
    WebsiteType.autre => 'Autre',
    WebsiteType.personnalise => 'Personnalisé',
  };
}

/// Lien avec une autre personne.
enum RelationType {
  assistant,
  frereOuSoeur,
  enfant,
  partenaireDomestique,
  pereOuMere,
  ami,
  manager,
  mere,
  pere,
  partenaire,
  recommandePar,
  proche,
  conjoint,
  autre,
  personnalise;

  String get wire => name;
  static RelationType fromWire(String? w) =>
      RelationType.values.where((e) => e.name == w).firstOrNull ?? RelationType.autre;

  String get label => switch (this) {
    RelationType.assistant => 'Assistant',
    RelationType.frereOuSoeur => 'Frère ou sœur',
    RelationType.enfant => 'Enfant',
    RelationType.partenaireDomestique => 'Partenaire domestique',
    RelationType.pereOuMere => 'Père ou mère',
    RelationType.ami => 'Ami',
    RelationType.manager => 'Manager',
    RelationType.mere => 'Mère',
    RelationType.pere => 'Père',
    RelationType.partenaire => 'Partenaire',
    RelationType.recommandePar => 'Recommandé par',
    RelationType.proche => 'Proche',
    RelationType.conjoint => 'Conjoint',
    RelationType.autre => 'Autre',
    RelationType.personnalise => 'Personnalisé',
  };
}

/// Messagerie instantanée.
enum ChatType {
  hangouts,
  aim,
  msn,
  yahoo,
  skype,
  qq,
  icq,
  jabber,
  autre,
  personnalise;

  String get wire => name;
  static ChatType fromWire(String? w) =>
      ChatType.values.where((e) => e.name == w).firstOrNull ?? ChatType.autre;

  String get label => switch (this) {
    ChatType.hangouts => 'Hangouts',
    ChatType.aim => 'AIM',
    ChatType.msn => 'MSN',
    ChatType.yahoo => 'Yahoo',
    ChatType.skype => 'Skype',
    ChatType.qq => 'QQ',
    ChatType.icq => 'ICQ',
    ChatType.jabber => 'Jabber',
    ChatType.autre => 'Autre',
    ChatType.personnalise => 'Personnalisé',
  };
}

/// Critère de tri de la liste de contacts (réglages).
enum ContactSortOrder {
  prenom,
  nom;

  String get wire => name;
  static ContactSortOrder fromWire(String? w) =>
      ContactSortOrder.values.where((e) => e.name == w).firstOrNull ?? ContactSortOrder.prenom;

  String get label => switch (this) {
    ContactSortOrder.prenom => 'Prénom',
    ContactSortOrder.nom => 'Nom de famille',
  };
}

/// Format d'affichage du nom (réglages).
enum NameFormat {
  prenomNom,
  nomPrenom;

  String get wire => name;
  static NameFormat fromWire(String? w) =>
      NameFormat.values.where((e) => e.name == w).firstOrNull ?? NameFormat.prenomNom;

  String get label => switch (this) {
    NameFormat.prenomNom => "D'abord le prénom",
    NameFormat.nomPrenom => "D'abord le nom de famille",
  };
}
