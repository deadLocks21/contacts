import 'package:contacts/core/domain/model/enums.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;

/// Traduction des libellés de champs entre le domaine et le carnet du système.
///
/// Les deux vocabulaires se recouvrent largement — ils décrivent le même
/// carnet — mais pas exactement : ce que le système ne sait pas nommer retombe
/// sur « Autre », et non sur une valeur inventée.

PhoneType phoneTypeFrom(fc.PhoneLabel label) => switch (label) {
  fc.PhoneLabel.mobile || fc.PhoneLabel.iPhone => PhoneType.mobile,
  fc.PhoneLabel.home => PhoneType.domicile,
  fc.PhoneLabel.work => PhoneType.professionnel,
  fc.PhoneLabel.faxWork => PhoneType.faxProfessionnel,
  fc.PhoneLabel.faxHome => PhoneType.faxPersonnel,
  fc.PhoneLabel.faxOther => PhoneType.autreFax,
  fc.PhoneLabel.main => PhoneType.principal,
  fc.PhoneLabel.pager => PhoneType.bipeur,
  fc.PhoneLabel.callback => PhoneType.rappel,
  fc.PhoneLabel.car => PhoneType.voiture,
  fc.PhoneLabel.companyMain => PhoneType.standardEntreprise,
  fc.PhoneLabel.isdn => PhoneType.isdn,
  fc.PhoneLabel.radio => PhoneType.radio,
  fc.PhoneLabel.telex => PhoneType.telex,
  fc.PhoneLabel.ttyTtd => PhoneType.ttyAts,
  fc.PhoneLabel.workMobile => PhoneType.mobileProfessionnel,
  fc.PhoneLabel.workPager => PhoneType.bipeurProfessionnel,
  fc.PhoneLabel.assistant => PhoneType.assistant,
  fc.PhoneLabel.mms => PhoneType.mms,
  fc.PhoneLabel.custom => PhoneType.personnalise,
  _ => PhoneType.autre,
};

fc.PhoneLabel phoneLabelOf(PhoneType type) => switch (type) {
  PhoneType.mobile => fc.PhoneLabel.mobile,
  PhoneType.domicile => fc.PhoneLabel.home,
  PhoneType.professionnel => fc.PhoneLabel.work,
  PhoneType.faxProfessionnel => fc.PhoneLabel.faxWork,
  PhoneType.faxPersonnel => fc.PhoneLabel.faxHome,
  PhoneType.autreFax => fc.PhoneLabel.faxOther,
  PhoneType.principal => fc.PhoneLabel.main,
  PhoneType.bipeur => fc.PhoneLabel.pager,
  PhoneType.rappel => fc.PhoneLabel.callback,
  PhoneType.voiture => fc.PhoneLabel.car,
  PhoneType.standardEntreprise => fc.PhoneLabel.companyMain,
  PhoneType.isdn => fc.PhoneLabel.isdn,
  PhoneType.radio => fc.PhoneLabel.radio,
  PhoneType.telex => fc.PhoneLabel.telex,
  PhoneType.ttyAts => fc.PhoneLabel.ttyTtd,
  PhoneType.mobileProfessionnel => fc.PhoneLabel.workMobile,
  PhoneType.bipeurProfessionnel => fc.PhoneLabel.workPager,
  PhoneType.assistant => fc.PhoneLabel.assistant,
  PhoneType.mms => fc.PhoneLabel.mms,
  PhoneType.personnalise => fc.PhoneLabel.custom,
  PhoneType.autre => fc.PhoneLabel.other,
};

EmailType emailTypeFrom(fc.EmailLabel label) => switch (label) {
  fc.EmailLabel.home || fc.EmailLabel.iCloud => EmailType.domicile,
  fc.EmailLabel.work => EmailType.professionnel,
  fc.EmailLabel.mobile => EmailType.mobile,
  fc.EmailLabel.custom => EmailType.personnalise,
  _ => EmailType.autre,
};

fc.EmailLabel emailLabelOf(EmailType type) => switch (type) {
  EmailType.domicile => fc.EmailLabel.home,
  EmailType.professionnel => fc.EmailLabel.work,
  EmailType.mobile => fc.EmailLabel.mobile,
  EmailType.personnalise => fc.EmailLabel.custom,
  EmailType.autre => fc.EmailLabel.other,
};

AddressType addressTypeFrom(fc.AddressLabel label) => switch (label) {
  fc.AddressLabel.home => AddressType.domicile,
  fc.AddressLabel.work => AddressType.professionnel,
  fc.AddressLabel.custom => AddressType.personnalise,
  _ => AddressType.autre,
};

fc.AddressLabel addressLabelOf(AddressType type) => switch (type) {
  AddressType.domicile => fc.AddressLabel.home,
  AddressType.professionnel => fc.AddressLabel.work,
  AddressType.personnalise => fc.AddressLabel.custom,
  AddressType.autre => fc.AddressLabel.other,
};

EventType eventTypeFrom(fc.EventLabel label) => switch (label) {
  fc.EventLabel.birthday => EventType.anniversaire,
  fc.EventLabel.anniversary => EventType.anniversaireDeMariage,
  fc.EventLabel.custom => EventType.personnalise,
  _ => EventType.autre,
};

fc.EventLabel eventLabelOf(EventType type) => switch (type) {
  EventType.anniversaire => fc.EventLabel.birthday,
  EventType.anniversaireDeMariage => fc.EventLabel.anniversary,
  EventType.personnalise => fc.EventLabel.custom,
  EventType.autre => fc.EventLabel.other,
};

WebsiteType websiteTypeFrom(fc.WebsiteLabel label) => switch (label) {
  fc.WebsiteLabel.profile => WebsiteType.profil,
  fc.WebsiteLabel.blog => WebsiteType.blog,
  fc.WebsiteLabel.home => WebsiteType.pageDAccueil,
  fc.WebsiteLabel.homepage => WebsiteType.pagePrincipale,
  fc.WebsiteLabel.work => WebsiteType.professionnel,
  fc.WebsiteLabel.ftp => WebsiteType.ftp,
  fc.WebsiteLabel.custom => WebsiteType.personnalise,
  _ => WebsiteType.autre,
};

fc.WebsiteLabel websiteLabelOf(WebsiteType type) => switch (type) {
  WebsiteType.profil => fc.WebsiteLabel.profile,
  WebsiteType.blog => fc.WebsiteLabel.blog,
  WebsiteType.pageDAccueil => fc.WebsiteLabel.home,
  WebsiteType.pagePrincipale => fc.WebsiteLabel.homepage,
  WebsiteType.professionnel => fc.WebsiteLabel.work,
  WebsiteType.ftp => fc.WebsiteLabel.ftp,
  WebsiteType.personnalise => fc.WebsiteLabel.custom,
  WebsiteType.autre => fc.WebsiteLabel.other,
};

ChatType chatTypeFrom(fc.SocialMediaLabel label) => switch (label) {
  fc.SocialMediaLabel.googleTalk => ChatType.hangouts,
  fc.SocialMediaLabel.aim => ChatType.aim,
  fc.SocialMediaLabel.msn => ChatType.msn,
  fc.SocialMediaLabel.yahoo => ChatType.yahoo,
  fc.SocialMediaLabel.skype => ChatType.skype,
  fc.SocialMediaLabel.qqchat => ChatType.qq,
  fc.SocialMediaLabel.icq => ChatType.icq,
  fc.SocialMediaLabel.jabber => ChatType.jabber,
  fc.SocialMediaLabel.custom => ChatType.personnalise,
  _ => ChatType.autre,
};

fc.SocialMediaLabel chatLabelOf(ChatType type) => switch (type) {
  ChatType.hangouts => fc.SocialMediaLabel.googleTalk,
  ChatType.aim => fc.SocialMediaLabel.aim,
  ChatType.msn => fc.SocialMediaLabel.msn,
  ChatType.yahoo => fc.SocialMediaLabel.yahoo,
  ChatType.skype => fc.SocialMediaLabel.skype,
  ChatType.qq => fc.SocialMediaLabel.qqchat,
  ChatType.icq => fc.SocialMediaLabel.icq,
  ChatType.jabber => fc.SocialMediaLabel.jabber,
  ChatType.personnalise => fc.SocialMediaLabel.custom,
  ChatType.autre => fc.SocialMediaLabel.other,
};

/// Préfixe des messageries qui ne sont pas des messageries.
///
/// Google Contacts sait attacher des **relations** (« Conjoint : Marie ») à une
/// fiche ; `flutter_contacts` n'expose pas la table correspondante du carnet
/// système. Plutôt que de perdre la donnée en silence, on la range dans une
/// messagerie personnalisée dont l'intitulé porte ce préfixe, ce qui la rend
/// reconnaissable au retour. Une autre application y verra une ligne de chat
/// au libellé inhabituel — c'est le prix de la conservation.
const relationLabelPrefix = 'relation:';
