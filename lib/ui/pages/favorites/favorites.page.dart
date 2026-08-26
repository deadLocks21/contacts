import 'package:contacts/ui/widgets/contact_list_view.widget.dart';
import 'package:contacts/ui/widgets/empty_state.widget.dart';
import 'package:flutter/material.dart';

/// Les contacts marqués d'une étoile, atteints depuis le tiroir.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoris')),
      body: const SafeArea(
        child: ContactListView(
          starredOnly: true,
          emptyState: EmptyState(
            icon: Icons.star_outline,
            title: 'Aucun favori',
            message: 'Ouvrez un contact et appuyez sur l\'étoile pour le retrouver ici.',
          ),
        ),
      ),
    );
  }
}
