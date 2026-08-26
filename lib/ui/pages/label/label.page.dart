import 'package:contacts/core/application/dtos/label.dto.dart';
import 'package:contacts/ui/providers/contact_data_providers.dart';
import 'package:contacts/ui/router/app_router.dart';
import 'package:contacts/ui/widgets/contact_list_view.widget.dart';
import 'package:contacts/ui/widgets/empty_state.widget.dart';
import 'package:contacts/ui/widgets/label_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Les contacts d'une étiquette, avec de quoi la renommer ou la supprimer.
class LabelPage extends ConsumerWidget {
  const LabelPage({super.key, required this.labelId});

  final String labelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = ref.watch(labelListProvider).value ?? const <LabelDto>[];
    final label = labels.where((l) => l.id == labelId).firstOrNull;

    // L'étiquette vient d'être supprimée depuis cette page : on referme.
    if (label == null && labels.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && context.canPop()) context.pop();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(label?.name ?? 'Étiquette'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'rename':
                  await renameLabelDialog(
                    context,
                    ref,
                    labelId: labelId,
                    currentName: label?.name ?? '',
                  );
                case 'delete':
                  final deleted = await deleteLabelDialog(
                    context,
                    ref,
                    labelId: labelId,
                    name: label?.name ?? '',
                  );
                  if (deleted && context.mounted) context.pop();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'rename', child: Text('Renommer l\'étiquette')),
              PopupMenuItem(value: 'delete', child: Text('Supprimer l\'étiquette')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ContactListView(
          labelId: labelId,
          emptyState: EmptyState(
            icon: Icons.label_outline,
            title: 'Aucun contact avec cette étiquette',
            message: 'Ajoutez-en un pour retrouver ici toutes les fiches concernées.',
            action: FilledButton.icon(
              onPressed: () => context.push('${AppRoutes.newContact}?etiquette=$labelId'),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Créer un contact'),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('${AppRoutes.newContact}?etiquette=$labelId'),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Créer un contact'),
      ),
    );
  }
}
