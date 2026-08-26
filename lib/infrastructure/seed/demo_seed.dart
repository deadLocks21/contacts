import 'package:contacts/core/domain/model/contact.dart';
import 'package:contacts/core/domain/model/contact_event.dart';
import 'package:contacts/core/domain/model/contact_label.dart';
import 'package:contacts/core/domain/model/contact_name.dart';
import 'package:contacts/core/domain/model/email_address.dart';
import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/core/domain/model/phone_number.dart';
import 'package:contacts/core/domain/model/postal_address.dart';
import 'package:contacts/core/domain/model/relation.dart';
import 'package:contacts/core/domain/model/entity_id.dart';
import 'package:contacts/core/domain/model/website.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/core/domain/services/label.repository.dart';

/// Carnet de démonstration, écrit **une seule fois**, au tout premier
/// démarrage : une app de contacts vide ne montre rien de ce qu'elle sait
/// faire. Dès qu'une fiche existe, le seed ne s'exécute plus — il n'écrasera
/// jamais les données de l'utilisateur.
///
/// Deux fiches font sciemment doublon (Julien Mercier) pour que « Fusionner et
/// corriger » ait de quoi travailler.
class DemoSeed {
  const DemoSeed(this._contacts, this._labels);

  final ContactRepository _contacts;
  final LabelRepository _labels;

  Future<bool> runIfEmpty({DateTime? now}) async {
    final existing = await _contacts.listAll(includeTrashed: true);
    if (existing.isNotEmpty) return false;
    if ((await _labels.listAll()).isNotEmpty) return false;

    final at = now ?? DateTime.now();
    final famille = ContactLabel.create('Famille', now: at);
    final travail = ContactLabel.create('Travail', now: at);
    final amis = ContactLabel.create('Amis', now: at);
    for (final label in [famille, travail, amis]) {
      await _labels.save(label);
    }

    Contact contact({
      String? first,
      String? last,
      String? company,
      String? jobTitle,
      List<PhoneNumber> phones = const [],
      List<EmailAddress> emails = const [],
      List<PostalAddress> addresses = const [],
      List<Website> websites = const [],
      List<ContactEvent> events = const [],
      List<Relation> relations = const [],
      String? notes,
      Set<EntityId> labelIds = const {},
      bool starred = false,
      int agedDays = 0,
    }) {
      final created = at.subtract(Duration(days: agedDays));
      return Contact(
        id: EntityId.generate(),
        name: ContactName(first: first, last: last),
        company: company,
        jobTitle: jobTitle,
        phones: phones,
        emails: emails,
        addresses: addresses,
        websites: websites,
        events: events,
        relations: relations,
        notes: notes,
        labelIds: labelIds,
        starred: starred,
        createdAt: created,
        updatedAt: created,
      );
    }

    await _contacts.saveAll([
      contact(
        first: 'Camille',
        last: 'Bernard',
        company: 'Atelier Bernard',
        jobTitle: 'Architecte',
        starred: true,
        agedDays: 320,
        phones: [
          PhoneNumber.create('06 12 45 78 90'),
          PhoneNumber.create('01 45 67 89 01', type: PhoneType.professionnel),
        ],
        emails: [
          EmailAddress.create('camille.bernard@atelier-bernard.fr', type: EmailType.professionnel),
          EmailAddress.create('camille.bernard@gmail.com'),
        ],
        addresses: [
          PostalAddress.create(
            street: '18 rue des Lilas',
            postcode: '75011',
            city: 'Paris',
            country: 'France',
          ),
        ],
        websites: [Website.create('atelier-bernard.fr', type: WebsiteType.professionnel)],
        events: [ContactEvent.create(day: 14, month: 3, year: 1987)],
        labelIds: {travail.id},
      ),
      contact(
        first: 'Julien',
        last: 'Mercier',
        company: 'Studio Nord',
        jobTitle: 'Développeur',
        agedDays: 290,
        phones: [PhoneNumber.create('06 88 21 45 63')],
        emails: [
          EmailAddress.create('julien.mercier@studionord.io', type: EmailType.professionnel),
        ],
        labelIds: {travail.id},
      ),
      // Doublon volontaire : même numéro, fiche plus pauvre.
      contact(
        first: 'Julien',
        last: 'Mercier',
        agedDays: 40,
        phones: [PhoneNumber.create('+33 6 88 21 45 63')],
        emails: [EmailAddress.create('jmercier@perso.fr')],
        notes: 'Rencontré au meetup Flutter Paris.',
      ),
      contact(
        first: 'Sophie',
        last: 'Lambert',
        starred: true,
        agedDays: 400,
        phones: [
          PhoneNumber.create('06 34 56 12 78'),
          PhoneNumber.create('04 78 12 34 56', type: PhoneType.domicile),
        ],
        emails: [EmailAddress.create('sophie.lambert@free.fr')],
        addresses: [
          PostalAddress.create(
            street: '5 quai Saint-Antoine',
            postcode: '69002',
            city: 'Lyon',
            country: 'France',
          ),
        ],
        events: [ContactEvent.create(day: 2, month: 9, year: 1990)],
        relations: [Relation.create('Marc Lambert', type: RelationType.conjoint)],
        labelIds: {famille.id, amis.id},
      ),
      contact(
        first: 'Marc',
        last: 'Lambert',
        agedDays: 400,
        phones: [PhoneNumber.create('06 91 23 45 67')],
        relations: [Relation.create('Sophie Lambert', type: RelationType.conjoint)],
        labelIds: {famille.id},
      ),
      contact(
        first: 'Élodie',
        last: 'Charpentier',
        company: 'Clinique du Parc',
        jobTitle: 'Kinésithérapeute',
        agedDays: 210,
        phones: [PhoneNumber.create('05 56 78 90 12', type: PhoneType.professionnel)],
        emails: [EmailAddress.create('contact@clinique-du-parc.fr', type: EmailType.professionnel)],
        addresses: [
          PostalAddress.create(
            street: '32 cours Victor Hugo',
            postcode: '33000',
            city: 'Bordeaux',
            country: 'France',
            type: AddressType.professionnel,
          ),
        ],
      ),
      contact(
        first: 'Thomas',
        last: 'Nguyen',
        company: 'Banque Populaire',
        jobTitle: 'Conseiller',
        agedDays: 180,
        phones: [PhoneNumber.create('01 53 24 66 10', type: PhoneType.professionnel)],
        emails: [EmailAddress.create('thomas.nguyen@bp.fr', type: EmailType.professionnel)],
        labelIds: {travail.id},
      ),
      contact(
        first: 'Amina',
        last: 'Diallo',
        starred: true,
        agedDays: 150,
        phones: [PhoneNumber.create('07 62 84 19 33')],
        emails: [EmailAddress.create('amina.diallo@outlook.fr')],
        events: [ContactEvent.create(day: 27, month: 6)],
        labelIds: {amis.id},
      ),
      contact(
        first: 'Pierre',
        last: 'Rousseau',
        agedDays: 130,
        phones: [PhoneNumber.create('06 45 78 91 23')],
        notes: 'Plombier — intervient le samedi matin.',
      ),
      contact(
        first: 'Léa',
        last: 'Fontaine',
        company: 'Le Petit Marché',
        agedDays: 95,
        phones: [PhoneNumber.create('02 40 12 78 56', type: PhoneType.professionnel)],
        addresses: [
          PostalAddress.create(
            street: '9 rue du Calvaire',
            postcode: '44000',
            city: 'Nantes',
            country: 'France',
          ),
        ],
        labelIds: {amis.id},
      ),
      contact(
        first: 'Antoine',
        last: 'Girard',
        jobTitle: 'Photographe',
        agedDays: 75,
        phones: [PhoneNumber.create('06 77 33 21 09')],
        emails: [EmailAddress.create('antoine@girard-photo.com', type: EmailType.professionnel)],
        websites: [Website.create('girard-photo.com')],
      ),
      contact(
        first: 'Nadia',
        last: 'Belkacem',
        company: 'Mairie de Montreuil',
        jobTitle: 'Chargée de mission',
        agedDays: 60,
        phones: [PhoneNumber.create('01 48 70 60 00', type: PhoneType.professionnel)],
        emails: [EmailAddress.create('n.belkacem@montreuil.fr', type: EmailType.professionnel)],
        labelIds: {travail.id},
      ),
      contact(
        first: 'Hugo',
        last: 'Petit',
        agedDays: 45,
        phones: [PhoneNumber.create('06 23 87 45 10')],
        events: [ContactEvent.create(day: 11, month: 11, year: 1995)],
        labelIds: {amis.id},
      ),
      contact(
        first: 'Chloé',
        last: 'Moreau',
        company: 'Éditions du Seuil',
        jobTitle: 'Attachée de presse',
        agedDays: 30,
        phones: [PhoneNumber.create('01 41 48 84 00', type: PhoneType.professionnel)],
        emails: [EmailAddress.create('chloe.moreau@seuil.com', type: EmailType.professionnel)],
      ),
      contact(
        first: 'Yann',
        last: 'Le Gall',
        agedDays: 20,
        phones: [PhoneNumber.create('06 09 55 41 27')],
        notes: 'Covoiturage Rennes → Paris le vendredi.',
      ),
      // Fiche d'entreprise : pas de nom de personne, seule la société parle.
      contact(
        company: 'Garage Delaunay',
        agedDays: 12,
        phones: [PhoneNumber.create('03 20 55 12 89', type: PhoneType.professionnel)],
        addresses: [
          PostalAddress.create(
            street: '77 rue de Lille',
            postcode: '59000',
            city: 'Lille',
            country: 'France',
            type: AddressType.professionnel,
          ),
        ],
      ),
    ]);
    return true;
  }
}
