import 'package:contacts/core/application/dtos/duplicate_group.dto.dart';
import 'package:contacts/infrastructure/providers/service_providers.dart';
import 'package:contacts/ui/providers/contact_data_providers.dart';
import 'package:contacts/ui/router/app_router.dart';
import 'package:contacts/ui/theme/app_colors.dart';
import 'package:contacts/ui/widgets/contact_tile.widget.dart';
import 'package:contacts/ui/widgets/empty_state.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// « Fusionner et corriger » : les fiches qui semblent décrire la même
/// personne, groupe par groupe.
class DuplicatesPage extends ConsumerWidget {
  const DuplicatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final groupsAsync = ref.watch(duplicateGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fusionner et corriger'),
        actions: [
          if ((groupsAsync.value?.length ?? 0) > 1)
            TextButton(
              onPressed: () => _mergeAll(context, ref, groupsAsync.value!),
              child: const Text('Tout fusionner'),
            ),
        ],
      ),
      body: SafeArea(
        child: groupsAsync.when(
          skipLoadingOnReload: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Erreur : $error')),
          data: (groups) {
            if (groups.isEmpty) {
              return const EmptyState(
                icon: Icons.verified_outlined,
                title: 'Tout est en ordre',
                message: 'Aucun doublon détecté dans votre carnet.',
              );
            }
            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Text(
                    'Fusionner réunit toutes les informations dans une seule fiche : rien '
                    'n\'est perdu.',
                    style: TextStyle(color: colors.textMuted, fontSize: 13, height: 1.4),
                  ),
                ),
                for (final group in groups) _DuplicateGroupCard(group: group),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _mergeAll(
    BuildContext context,
    WidgetRef ref,
    List<DuplicateGroupDto> groups,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Fusionner ${groups.length} groupes ?'),
        content: const Text('Chaque groupe deviendra une fiche unique.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Fusionner')),
        ],
      ),
    );
    if (confirmed != true) return;

    final merge = ref.read(organizeServiceProvider).merge;
    for (final group in groups) {
      await merge.execute([for (final c in group.contacts) c.id]);
    }
    messenger.showSnackBar(SnackBar(content: Text('${groups.length} groupes fusionnés.')));
  }
}

/// Un groupe de doublons : le motif du rapprochement, les fiches, et le bouton
/// qui les réunit.
class _DuplicateGroupCard extends ConsumerWidget {
  const _DuplicateGroupCard({required this.group});

  final DuplicateGroupDto group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    group.title.isEmpty ? '(Sans nom)' : group.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Text(group.reason.label, style: TextStyle(fontSize: 12, color: colors.textMuted)),
              ],
            ),
          ),
          for (final contact in group.contacts)
            ContactTile(
              contact: contact,
              dense: true,
              showStar: false,
              onTap: () => context.push(AppRoutes.contact(contact.id)),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: TextButton.icon(
                onPressed: () => ref.read(organizeServiceProvider).merge.execute([
                  for (final c in group.contacts) c.id,
                ]),
                icon: const Icon(Icons.merge_type, size: 20),
                label: const Text('Fusionner'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
