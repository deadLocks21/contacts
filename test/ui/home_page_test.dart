import 'package:contacts/core/domain/model/contact_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';
import '../support/widget_harness.dart';

void main() {
  testWidgets('affiche les contacts groupés par initiale', (tester) async {
    await pumpContactsApp(
      tester,
      contacts: [
        aContact(first: 'Bruno', last: 'Alric'),
        aContact(first: 'Alice', last: 'Zola', jobTitle: 'Notaire'),
      ],
    );

    expect(find.text('Alice Zola'), findsOneWidget);
    expect(find.text('Bruno Alric'), findsOneWidget);
    expect(find.text('Notaire'), findsOneWidget);
    expect(find.text('2 contacts'), findsOneWidget);
    // Les en-têtes de section reprennent l'initiale du prénom (tri par défaut).
    expect(find.widgetWithText(Container, 'A'), findsWidgets);
  });

  testWidgets('annonce un carnet vide', (tester) async {
    await pumpContactsApp(tester);

    expect(find.text('Aucun contact'), findsOneWidget);
  });

  testWidgets('ouvre la fiche au clic sur une ligne', (tester) async {
    await pumpContactsApp(
      tester,
      contacts: [
        aContact(first: 'Marie', last: 'Dupont', phones: ['0612345678']),
      ],
    );

    await tester.tap(find.text('Marie Dupont'));
    await tester.pumpAndSettle();

    expect(find.text('06 12 34 56 78'), findsOneWidget);
    expect(find.text('Coordonnées'), findsOneWidget);
    expect(find.text('Appeler'), findsOneWidget);
  });

  testWidgets('un appui long ouvre la sélection multiple', (tester) async {
    await pumpContactsApp(
      tester,
      contacts: [
        aContact(first: 'Marie'),
        aContact(first: 'Paul'),
      ],
    );

    await tester.longPress(find.text('Marie'));
    await tester.pumpAndSettle();
    expect(find.text('1 sélectionné'), findsOneWidget);

    await tester.tap(find.text('Paul'));
    await tester.pumpAndSettle();
    expect(find.text('2 sélectionnés'), findsOneWidget);

    // Fermer la sélection rend la barre de recherche.
    await tester.tap(find.byTooltip('Quitter la sélection'));
    await tester.pumpAndSettle();
    expect(find.text('Rechercher des contacts'), findsOneWidget);
  });

  testWidgets('supprimer depuis la sélection met à la corbeille', (tester) async {
    await pumpContactsApp(tester, contacts: [aContact(first: 'Marie')]);

    await tester.longPress(find.text('Marie'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Supprimer'));
    await tester.pumpAndSettle();
    expect(find.textContaining('30 jours'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
    await tester.pumpAndSettle();

    expect(find.text('Marie'), findsNothing);
    expect(find.text('Aucun contact'), findsOneWidget);
  });

  testWidgets('les puces de filtre restreignent la liste', (tester) async {
    await pumpContactsApp(
      tester,
      contacts: [
        aContact(first: 'Avec', last: 'Numero', phones: ['0612345678']),
        aContact(first: 'Sans', last: 'Numero'),
      ],
    );

    await tester.tap(find.byKey(const Key('filtersButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contacts avec téléphone'));
    await tester.pumpAndSettle();

    expect(find.text('Avec Numero'), findsOneWidget);
    expect(find.text('Sans Numero'), findsNothing);
  });

  testWidgets('la feuille des étiquettes filtre la liste', (tester) async {
    final travail = ContactLabel.create('Travail', now: testNow);
    await pumpContactsApp(
      tester,
      labels: [travail],
      contacts: [
        aContact(first: 'Collegue', labelIds: {travail.id}),
        aContact(first: 'Autre'),
      ],
    );

    await tester.tap(find.byKey(const Key('labelsButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Travail'));
    await tester.pumpAndSettle();

    expect(find.text('Collegue'), findsOneWidget);
    expect(find.text('Autre'), findsNothing);
    expect(find.byKey(const Key('viewSelector')), findsOneWidget);
  });

  testWidgets('nomme la vue courante dans le sélecteur', (tester) async {
    await pumpContactsApp(tester, contacts: [aContact(first: 'Marie', starred: true)]);

    expect(find.text('Tous les contacts'), findsOneWidget);

    await tester.tap(find.byKey(const Key('viewSelector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favoris').last);
    await tester.pumpAndSettle();

    expect(find.text('Favoris'), findsOneWidget);
    expect(find.text('Marie'), findsOneWidget);
  });

  testWidgets('l\'avatar du compte ouvre les paramètres', (tester) async {
    await pumpContactsApp(tester, contacts: [aContact(first: 'Marie')]);

    await tester.tap(find.byKey(const Key('accountAvatar')));
    await tester.pumpAndSettle();

    expect(find.text('Paramètres'), findsOneWidget);
    expect(find.text('Format des noms'), findsOneWidget);
  });
}
