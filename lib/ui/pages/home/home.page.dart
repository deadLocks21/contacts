import 'package:contacts/ui/pages/home/widgets/contacts_filter_bar.widget.dart';
import 'package:contacts/ui/pages/home/widgets/contacts_search_bar.widget.dart';
import 'package:contacts/ui/providers/contact_data_providers.dart';
import 'package:contacts/ui/providers/contact_view.provider.dart';
import 'package:contacts/ui/providers/selection.provider.dart';
import 'package:contacts/ui/router/app_router.dart';
import 'package:contacts/ui/theme/app_colors.dart';
import 'package:contacts/ui/widgets/contact_list_view.widget.dart';
import 'package:contacts/ui/widgets/empty_state.widget.dart';
import 'package:contacts/ui/widgets/selection_app_bar.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// L'onglet « Contacts » : recherche, sélecteur de vue et filtres, puis la
/// liste alphabétique.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final selection = ref.watch(contactSelectionProvider);
    final view = ref.watch(contactViewProvider);
    final list = ref
        .watch(
          contactListProvider(
            labelId: view.labelId,
            starredOnly: view.starredOnly,
            filters: view.filters,
          ),
        )
        .value;

    return PopScope(
      // Le retour système referme d'abord le mode sélection : quitter l'app
      // alors qu'on a des fiches cochées n'est jamais l'intention.
      canPop: selection.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ref.read(contactSelectionProvider.notifier).clear();
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: selection.isEmpty
            ? null
            : SelectionAppBar(allIds: [for (final c in list?.all ?? const []) c.id]),
        body: SafeArea(
          child: ContactListView(
            labelId: view.labelId,
            starredOnly: view.starredOnly,
            filters: view.filters,
            header: selection.isEmpty
                ? Column(
                    children: [
                      ContactsSearchBar(
                        onTap: () => context.push(AppRoutes.search),
                        onAvatarTap: () => context.push(AppRoutes.settings),
                      ),
                      const ContactsFilterBar(),
                    ],
                  )
                : null,
            emptyState: _emptyState(context, view),
          ),
        ),
        floatingActionButton: selection.isNotEmpty
            ? null
            : FloatingActionButton(
                key: const Key('createContactFab'),
                tooltip: 'Créer un contact',
                onPressed: () => context.push(
                  view.labelId == null
                      ? AppRoutes.newContact
                      : '${AppRoutes.newContact}?etiquette=${view.labelId}',
                ),
                child: const Icon(Icons.add),
              ),
      ),
    );
  }

  /// L'écran vide dit *pourquoi* la liste est vide : un carnet neuf et un
  /// filtre trop étroit n'appellent pas la même action.
  Widget _emptyState(BuildContext context, ContactViewState view) {
    if (!view.isFiltered) {
      return const EmptyState(
        icon: Icons.person_outline,
        title: 'Aucun contact',
        message: 'Appuyez sur « + » pour créer votre premier contact.',
      );
    }
    if (view.starredOnly) {
      return const EmptyState(
        icon: Icons.star_outline,
        title: 'Aucun favori',
        message: 'Ouvrez un contact et appuyez sur l\'étoile pour le retrouver ici.',
      );
    }
    return EmptyState(
      icon: Icons.filter_list_off,
      title: 'Aucun contact ne correspond',
      message: view.labelName == null
          ? 'Aucune fiche ne satisfait les filtres actifs.'
          : 'Aucune fiche ne porte l\'étiquette « ${view.labelName} » avec ces filtres.',
    );
  }
}
