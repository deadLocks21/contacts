import 'package:contacts/core/domain/model/contact_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';
import '../support/widget_harness.dart';

void main() {
  testWidgets('crée un contact depuis le formulaire', (tester) async {
    await pumpContactsApp(tester);

    await tester.tap(find.byKey(const Key('createContactFab')));
    await tester.pumpAndSettle();
    expect(find.text('Créer un contact'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Prénom'), 'Marie');
    await tester.enterText(find.widgetWithText(TextFormField, 'Nom de famille'), 'Dupont');
    await tester.enterText(find.widgetWithText(TextFormField, 'Téléphone'), '0612345678');
    await tester.tap(find.byKey(const Key('saveContact')));
    await tester.pumpAndSettle();

    expect(find.text('Marie Dupont'), findsOneWidget);
    expect(find.text('1 contact'), findsOneWidget);
  });

  testWidgets('refuse un formulaire entièrement vide', (tester) async {
    await pumpContactsApp(tester);

    await tester.tap(find.byKey(const Key('createContactFab')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveContact')));
    await tester.pumpAndSettle();

    expect(find.textContaining('au moins un champ'), findsOneWidget);
  });

  testWidgets('modifie une fiche existante et vide un champ', (tester) async {
    await pumpContactsApp(
      tester,
      contacts: [aContact(first: 'Marie', last: 'Dupont', company: 'BNP')],
    );

    await tester.tap(find.text('Marie Dupont'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editContactFab')));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Société'), '');
    await tester.enterText(find.widgetWithText(TextFormField, 'Prénom'), 'Marion');
    await tester.tap(find.byKey(const Key('saveContact')));
    await tester.pumpAndSettle();

    expect(find.text('Marion Dupont'), findsOneWidget);
    expect(find.text('BNP'), findsNothing);
  });

  testWidgets('déplie les autres champs à la demande', (tester) async {
    await pumpContactsApp(tester);

    await tester.tap(find.byKey(const Key('createContactFab')));
    await tester.pumpAndSettle();
    expect(find.text('Notes'), findsNothing);

    final form = find
        .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
        .first;
    await tester.scrollUntilVisible(find.text('Autres champs'), 200, scrollable: form);
    await tester.tap(find.text('Autres champs'));
    await tester.pumpAndSettle();

    expect(find.text('Ajouter une adresse'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Notes'), 200, scrollable: form);
    expect(find.text('Notes'), findsOneWidget);
  });

  testWidgets('ajoute et retire une ligne de téléphone', (tester) async {
    await pumpContactsApp(tester);

    await tester.tap(find.byKey(const Key('createContactFab')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'Téléphone'), findsOneWidget);

    await tester.tap(find.text('Ajouter un numéro'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'Téléphone'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Supprimer cette ligne').first);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'Téléphone'), findsOneWidget);
  });

  testWidgets('coche une étiquette à la création', (tester) async {
    final travail = ContactLabel.create('Travail', now: testNow);
    await pumpContactsApp(tester, labels: [travail]);

    await tester.tap(find.byKey(const Key('createContactFab')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Travail'));
    await tester.enterText(find.widgetWithText(TextFormField, 'Prénom'), 'Collegue');
    await tester.tap(find.byKey(const Key('saveContact')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('labelsButton')));
    await tester.pumpAndSettle();
    // Le compteur de l'étiquette reflète la fiche qui vient d'être créée.
    expect(find.widgetWithText(ListTile, 'Travail'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });
}
