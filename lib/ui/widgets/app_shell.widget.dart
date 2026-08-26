import 'package:contacts/ui/pages/home/widgets/contacts_drawer.widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Coquille des deux onglets du bas : « Contacts » et « Organiser ».
///
/// L'`IndexedStack` du shell conserve la pile et le défilement de chaque
/// onglet — revenir sur « Contacts » ne repart pas du haut de la liste.
///
/// Le tiroir de navigation est porté **ici** et non par la page d'accueil :
/// posé sur le `Scaffold` intérieur, il laisserait la barre d'onglets visible
/// en dessous, alors qu'il doit recouvrir tout l'écran.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return AppShellScope(
      openDrawer: () => _scaffoldKey.currentState?.openDrawer(),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const ContactsDrawer(),
        body: widget.shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: widget.shell.currentIndex,
          // `initialLocation: true` sur l'onglet déjà actif = retour à sa
          // racine, le geste attendu quand on retape l'onglet courant.
          onDestinationSelected: (index) =>
              widget.shell.goBranch(index, initialLocation: index == widget.shell.currentIndex),
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
      ),
    );
  }
}

/// Donne aux pages des onglets de quoi ouvrir le tiroir de la coquille, que
/// `Scaffold.of` ne peut pas atteindre depuis leur propre `Scaffold`.
class AppShellScope extends InheritedWidget {
  const AppShellScope({super.key, required this.openDrawer, required super.child});

  final VoidCallback openDrawer;

  static AppShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppShellScope>();

  @override
  bool updateShouldNotify(AppShellScope oldWidget) => openDrawer != oldWidget.openDrawer;
}
