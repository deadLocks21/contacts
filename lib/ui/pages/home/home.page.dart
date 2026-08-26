import 'package:contacts/ui/pages/home/widgets/contacts_search_bar.widget.dart';
import 'package:contacts/ui/providers/contact_data_providers.dart';
import 'package:contacts/ui/providers/selection.provider.dart';
import 'package:contacts/ui/router/app_router.dart';
import 'package:contacts/ui/theme/app_colors.dart';
import 'package:contacts/ui/widgets/app_shell.widget.dart';
import 'package:contacts/ui/widgets/contact_avatar.widget.dart';
import 'package:contacts/ui/widgets/contact_list_view.widget.dart';
import 'package:contacts/ui/widgets/selection_app_bar.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// L'écran d'accueil : barre de recherche, liste alphabétique, bouton
/// « Créer un contact ».
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final selection = ref.watch(contactSelectionProvider);
    final list = ref.watch(contactListProvider()).value;

    return PopScope(
      // Le retour système referme d'abord le mode sélection : quitter l'app
      // alors qu'on a des fiches cochées n'est jamais l'intention.
      canPop: selection.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ref.read(contactSelectionProvider.notifier).clear();
      },
      child: Scaffold(
        appBar: selection.isEmpty
            ? null
            : SelectionAppBar(allIds: [for (final c in list?.all ?? const []) c.id]),
        body: SafeArea(
          child: ContactListView(
            header: selection.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: ContactsSearchBar(
                      hint: 'Rechercher des contacts',
                      onMenuPressed: AppShellScope.maybeOf(context)?.openDrawer,
                      onTap: () => context.push(AppRoutes.search),
                      trailing: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: ContactAvatar(initials: 'T', colorKey: 'moi', size: 32),
                      ),
                    ),
                  )
                : null,
          ),
        ),
        floatingActionButton: selection.isNotEmpty
            ? null
            : FloatingActionButton.extended(
                key: const Key('createContactFab'),
                onPressed: () => context.push(AppRoutes.newContact),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Créer un contact'),
              ),
        backgroundColor: colors.background,
      ),
    );
  }
}
