import 'package:contacts/core/application/dtos/label.dto.dart';
import 'package:contacts/ui/providers/contact_data_providers.dart';
import 'package:contacts/ui/providers/contact_view.provider.dart';
import 'package:contacts/ui/theme/app_colors.dart';
import 'package:contacts/ui/widgets/label_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// La feuille des étiquettes, ouverte par l'icône en forme d'étiquette :
/// créer une étiquette, ou filtrer la liste sur l'une d'elles.
Future<void> showLabelsSheet(BuildContext context, WidgetRef ref) => showModalBottomSheet<void>(
  context: context,
  // Navigator racine : sans lui la feuille s'arrête au-dessus de la barre
  // d'onglets, qui resterait allumée sous une feuille modale.
  useRootNavigator: true,
  builder: (_) => const _LabelsSheet(),
);

class _LabelsSheet extends ConsumerWidget {
  const _LabelsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final labels = ref.watch(labelListProvider).value ?? const <LabelDto>[];
    final view = ref.watch(contactViewProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Étiquettes', style: TextStyle(fontSize: 16, color: colors.textMuted)),
            ),
          ),
          ListTile(
            leading: Icon(Icons.add, color: colors.accent),
            title: Text('Créer une étiquette', style: TextStyle(color: colors.accent)),
            onTap: () async {
              final navigator = Navigator.of(context);
              await createLabelDialog(context, ref);
              navigator.pop();
            },
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final label in labels)
                  ListTile(
                    leading: const Icon(Icons.label_outline),
                    title: Text(label.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${label.contactCount}', style: TextStyle(color: colors.textMuted)),
                        PopupMenuButton<String>(
                          tooltip: 'Gérer l\'étiquette',
                          onSelected: (value) async {
                            final navigator = Navigator.of(context);
                            if (value == 'rename') {
                              await renameLabelDialog(
                                context,
                                ref,
                                labelId: label.id,
                                currentName: label.name,
                              );
                            } else {
                              final deleted = await deleteLabelDialog(
                                context,
                                ref,
                                labelId: label.id,
                                name: label.name,
                              );
                              if (deleted && label.id == view.labelId) {
                                ref.read(contactViewProvider.notifier).showAll();
                              }
                            }
                            navigator.pop();
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'rename', child: Text('Renommer')),
                            PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                          ],
                        ),
                      ],
                    ),
                    selected: label.id == view.labelId,
                    selectedTileColor: colors.accentSoft,
                    onTap: () {
                      ref.read(contactViewProvider.notifier).showLabel(label.id, label.name);
                      Navigator.of(context).pop();
                    },
                  ),
                if (view.labelId != null)
                  ListTile(
                    leading: const Icon(Icons.people_outline),
                    title: const Text('Tous les contacts'),
                    onTap: () {
                      ref.read(contactViewProvider.notifier).showAll();
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
