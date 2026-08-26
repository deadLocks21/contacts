import 'package:contacts/ui/providers/contact_data_providers.dart';
import 'package:contacts/ui/router/app_router.dart';
import 'package:contacts/ui/theme/app_colors.dart';
import 'package:contacts/ui/widgets/contact_tile.widget.dart';
import 'package:contacts/ui/widgets/empty_state.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// La recherche plein écran : la frappe filtre le carnet à chaque caractère.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  var _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final results = ref.watch(searchResultsProvider(_query));

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour',
          onPressed: () => context.pop(),
        ),
        title: TextField(
          key: const Key('searchField'),
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Rechercher des contacts',
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: TextStyle(fontSize: 18, color: colors.textPrimary),
          onChanged: (value) => setState(() => _query = value),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Effacer',
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: SafeArea(
        child: _query.trim().isEmpty
            ? const EmptyState(
                icon: Icons.search,
                title: 'Rechercher dans vos contacts',
                message: 'Nom, société, numéro, adresse e-mail — tout est indexé.',
              )
            : results.when(
                skipLoadingOnReload: true,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Erreur : $error')),
                data: (contacts) {
                  if (contacts.isEmpty) {
                    return EmptyState(
                      icon: Icons.person_search_outlined,
                      title: 'Aucun contact trouvé',
                      message: 'Aucune fiche ne correspond à « $_query ».',
                    );
                  }
                  return ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) => ContactTile(
                      contact: contacts[index],
                      onTap: () => context.push(AppRoutes.contact(contacts[index].id)),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
