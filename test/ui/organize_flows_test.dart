import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';
import '../support/widget_harness.dart';

void main() {
  Future<void> openOrganize(WidgetTester tester) async {
    await tester.tap(find.text('Organiser'));
    await tester.pumpAndSettle();
  }

  /// La fenêtre de test est plus courte qu'un téléphone : certaines lignes de
  /// l'écran « Organiser » ne sont visibles qu'après défilement.
  Future<void> scrollTo(WidgetTester tester, Finder target) => tester.scrollUntilVisible(
    target,
    200,
    scrollable: find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)).first,
  );

  testWidgets('l\'onglet Organiser annonce les doublons et le carnet', (tester) async {
    await pumpContactsApp(
      tester,
      contacts: [
        aContact(first: 'Julien', last: 'Mercier', phones: ['06 88 21 45 63']),
        aContact(first: 'Julien', phones: ['+33 6 88 21 45 63']),
      ],
    );

    await openOrganize(tester);

    expect(find.text('2 contacts'), findsOneWidget);
    expect(find.text('1 doublon détecté'), findsOneWidget);
    expect(find.text('1 doublon à examiner'), findsOneWidget);
  });

  testWidgets('fusionne un groupe de doublons', (tester) async {
    await pumpContactsApp(
      tester,
      contacts: [
        aContact(
          first: 'Julien',
          last: 'Mercier',
          phones: ['06 88 21 45 63'],
          createdAt: DateTime.utc(2024),
        ),
        aContact(
          first: 'Julien',
          company: 'Studio Nord',
          phones: ['+33 6 88 21 45 63'],
          createdAt: DateTime.utc(2026),
        ),
      ],
    );

    await openOrganize(tester);
    await tester.tap(find.text('Fusionner et corriger'));
    await tester.pumpAndSettle();
    expect(find.text('Même numéro de téléphone'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Fusionner'));
    await tester.pumpAndSettle();

    expect(find.text('Tout est en ordre'), findsOneWidget);
  });

  testWidgets('la corbeille annonce le compte à rebours et restaure', (tester) async {
    await pumpContactsApp(
      tester,
      trashed: [aContact(first: 'Marie', deletedAt: DateTime.now())],
    );

    await openOrganize(tester);
    await tester.tap(find.text('Corbeille'));
    await tester.pumpAndSettle();

    expect(find.text('Marie'), findsOneWidget);
    expect(find.textContaining('Suppression définitive dans 30 jours'), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restaurer'));
    await tester.pumpAndSettle();

    expect(find.text('La corbeille est vide'), findsOneWidget);
  });

  testWidgets('les paramètres changent le tri de la liste', (tester) async {
    await pumpContactsApp(
      tester,
      contacts: [
        aContact(first: 'Bruno', last: 'Alric'),
        aContact(first: 'Alice', last: 'Zola'),
      ],
    );

    await openOrganize(tester);
    await scrollTo(tester, find.text('Paramètres'));
    await tester.tap(find.text('Paramètres'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trier par'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nom de famille'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contacts').last);
    await tester.pumpAndSettle();

    // Trié par nom de famille : Alric passe devant Zola.
    final noms = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList();
    expect(noms.indexOf('Bruno Alric') < noms.indexOf('Alice Zola'), isTrue);
  });

  testWidgets('l\'onglet Faits marquants met en avant favoris et anniversaires', (tester) async {
    await pumpContactsApp(
      tester,
      contacts: [aContact(first: 'Amina', last: 'Diallo', starred: true)],
    );

    await tester.tap(find.text('Faits marquants'));
    await tester.pumpAndSettle();

    expect(find.text('Favoris'), findsOneWidget);
    expect(find.text('Amina Diallo'), findsWidgets);
    expect(find.text('Ajoutez des anniversaires'), findsOneWidget);
  });
}
