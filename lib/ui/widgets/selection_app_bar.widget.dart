import 'package:contacts/infrastructure/providers/service_providers.dart';
import 'package:contacts/ui/providers/selection.provider.dart';
import 'package:contacts/ui/utils/contact_actions.dart';
import 'package:contacts/ui/widgets/label_picker.sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Barre de titre du mode sélection : « N sélectionnés » et les actions qui
/// s'appliquent au lot (favoris, corbeille, étiquettes, partage).
class SelectionAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const SelectionAppBar({super.key, required this.allIds});

  /// Tous les identifiants affichés — pour « Tout sélectionner ».
  final List<String> allIds;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(contactSelectionProvider);
    final notifier = ref.read(contactSelectionProvider.notifier);

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'Quitter la sélection',
        onPressed: notifier.clear,
      ),
      title: Text('${selection.length} sélectionné${selection.length > 1 ? 's' : ''}'),
      actions: [
        IconButton(
          icon: const Icon(Icons.star_outline),
          tooltip: 'Ajouter aux favoris',
          onPressed: () async {
            await ref
                .read(contactsServiceProvider)
                .toggleStar
                .execute(selection, starred: true);
            notifier.clear();
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Supprimer',
          onPressed: () async {
            final ids = {...selection};
            final confirmed = await confirmMoveToTrash(context, count: ids.length);
            if (!confirmed) return;
            await ref.read(contactsServiceProvider).moveToTrash.execute(ids);
            notifier.clear();
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'labels':
                await showLabelPicker(
                  context,
                  ref,
                  contactIds: {...selection},
                  initiallyApplied: const {},
                  partiallyApplied: const {},
                );
                notifier.clear();
              case 'share':
                await shareContacts(ref, ids: {...selection});
                notifier.clear();
              case 'unstar':
                await ref
                    .read(contactsServiceProvider)
                    .toggleStar
                    .execute(selection, starred: false);
                notifier.clear();
              case 'all':
                notifier.selectAll(allIds);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'all', child: Text('Tout sélectionner')),
            PopupMenuItem(value: 'labels', child: Text('Modifier les étiquettes')),
            PopupMenuItem(value: 'unstar', child: Text('Retirer des favoris')),
            PopupMenuItem(value: 'share', child: Text('Partager')),
          ],
        ),
      ],
    );
  }
}
