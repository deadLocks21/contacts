import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Coquille des deux onglets du bas : « Contacts » et « Organiser ».
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
            icon: Icon(Icons.contacts_outlined),
            selectedIcon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          NavigationDestination(
            icon: Icon(Icons.playlist_add_check_outlined),
            selectedIcon: Icon(Icons.playlist_add_check),
            label: 'Organiser',
          ),
        ],
      ),
    );
  }
}
