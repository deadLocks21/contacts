import 'package:contacts/ui/pages/contact_detail/contact_detail.page.dart';
import 'package:contacts/ui/pages/contact_edit/contact_edit.page.dart';
import 'package:contacts/ui/pages/duplicates/duplicates.page.dart';
import 'package:contacts/ui/pages/highlights/highlights.page.dart';
import 'package:contacts/ui/pages/home/home.page.dart';
import 'package:contacts/ui/pages/organize/organize.page.dart';
import 'package:contacts/ui/pages/search/search.page.dart';
import 'package:contacts/ui/pages/settings/settings.page.dart';
import 'package:contacts/ui/pages/trash/trash.page.dart';
import 'package:contacts/ui/widgets/app_shell.widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

abstract final class AppRoutes {
  static const contacts = '/';
  static const highlights = '/faits-marquants';
  static const organize = '/organiser';
  static const search = '/recherche';
  static const newContact = '/contact/nouveau';
  static const duplicates = '/organiser/doublons';
  static const trash = '/corbeille';
  static const settings = '/parametres';

  static String contact(String id) => '/contact/$id';
  static String editContact(String id) => '/contact/$id/modifier';
}

/// Router unique. Les trois onglets du bas (« Contacts », « Faits marquants »
/// et « Organiser ») sont portés par un `StatefulShellRoute` : chacun garde sa
/// pile et sa position de défilement quand on passe de l'un à l'autre, comme
/// dans Google Contacts.
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.contacts,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.contacts, builder: (_, _) => const HomePage())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: AppRoutes.highlights, builder: (_, _) => const HighlightsPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.organize, builder: (_, _) => const OrganizePage())],
          ),
        ],
      ),
      GoRoute(path: AppRoutes.search, builder: (_, _) => const SearchPage()),
      GoRoute(
        path: AppRoutes.newContact,
        builder: (_, state) => ContactEditPage(labelId: state.uri.queryParameters['etiquette']),
      ),
      GoRoute(
        path: '/contact/:id',
        builder: (_, state) => ContactDetailPage(contactId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'modifier',
            builder: (_, state) => ContactEditPage(contactId: state.pathParameters['id']),
          ),
        ],
      ),
      GoRoute(path: AppRoutes.duplicates, builder: (_, _) => const DuplicatesPage()),
      GoRoute(path: AppRoutes.trash, builder: (_, _) => const TrashPage()),
      GoRoute(path: AppRoutes.settings, builder: (_, _) => const SettingsPage()),
    ],
    errorBuilder: (_, state) =>
        Scaffold(body: Center(child: Text('Page introuvable : ${state.uri}'))),
  );
}
