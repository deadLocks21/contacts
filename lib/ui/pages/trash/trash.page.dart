import 'package:contacts/infrastructure/providers/service_providers.dart';
import 'package:contacts/ui/providers/contact_data_providers.dart';
import 'package:contacts/ui/router/app_router.dart';
import 'package:contacts/ui/theme/app_colors.dart';
import 'package:contacts/ui/widgets/contact_tile.widget.dart';
import 'package:contacts/ui/widgets/empty_state.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// La corbeille : les fiches supprimées, restaurables 30 jours durant.
class TrashPage extends ConsumerWidget {
  const TrashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final entriesAsync = ref.watch(trashEntriesProvider);
    final entries = entriesAsync.value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Corbeille'),
        actions: [
          if (entries.isNotEmpty)
            TextButton(
              onPressed: () => _emptyTrash(context, ref, count: entries.length),
              child: const Text('Vider'),
            ),
        ],
      ),
      body: SafeArea(
        child: entriesAsync.when(
          skipLoadingOnReload: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Erreur : $error')),
          data: (entries) {
            if (entries.isEmpty) {
              return const EmptyState(
                icon: Icons.delete_outline,
                title: 'La corbeille est vide',
                message: 'Les contacts supprimés y restent 30 jours avant disparition.',
              );
            }
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Text(
                    'Les contacts de la corbeille sont définitivement supprimés au bout de '
                    '30 jours.',
                    style: TextStyle(color: colors.textMuted, fontSize: 13, height: 1.4),
                  ),
                ),
                for (final entry in entries)
                  ContactTile(
                    contact: entry.contact,
                    subtitleOverride: entry.countdown,
                    showStar: false,
                    onTap: () => context.push(AppRoutes.contact(entry.contact.id)),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        final service = ref.read(organizeServiceProvider);
                        if (value == 'restore') {
                          await service.restore.execute([entry.contact.id]);
                        } else {
                          await service.deleteForever.execute([entry.contact.id]);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'restore', child: Text('Restaurer')),
                        PopupMenuItem(value: 'delete', child: Text('Supprimer définitivement')),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _emptyTrash(BuildContext context, WidgetRef ref, {required int count}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vider la corbeille ?'),
        content: Text(
          count == 1
              ? 'Ce contact sera définitivement supprimé.'
              : 'Ces $count contacts seront définitivement supprimés.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Vider')),
        ],
      ),
    );
    if (confirmed != true) return;
    final entries = ref.read(trashEntriesProvider).value ?? const [];
    await ref.read(organizeServiceProvider).deleteForever.execute([
      for (final e in entries) e.contact.id,
    ]);
  }
}
