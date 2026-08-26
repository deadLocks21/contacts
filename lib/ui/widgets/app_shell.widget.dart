import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Coquille des trois onglets du bas : « Contacts », « Faits marquants » et
/// « Organiser ».
///
/// L'`IndexedStack` du shell conserve la pile et le défilement de chaque
/// onglet — revenir sur « Contacts » ne repart pas du haut de la liste.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        // `initialLocation: true` sur l'onglet déjà actif = retour à sa racine,
        // le geste attendu quand on retape l'onglet courant.
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Contacts',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Faits marquants',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Organiser',
          ),
        ],
      ),
    );
  }
}
