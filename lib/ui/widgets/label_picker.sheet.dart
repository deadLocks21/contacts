import 'package:contacts/core/application/dtos/label.dto.dart';
import 'package:contacts/infrastructure/providers/service_providers.dart';
import 'package:contacts/ui/providers/contact_data_providers.dart';
import 'package:contacts/ui/widgets/label_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Choisit les étiquettes d'un ou plusieurs contacts.
///
/// Une case peut être **partiellement** cochée quand la sélection multiple
/// mélange des fiches qui portent l'étiquette et d'autres non ; la valider
/// l'applique à toutes, la décocher la retire à toutes.
Future<void> showLabelPicker(
  BuildContext context,
  WidgetRef ref, {
  required Set<String> contactIds,
  required Set<String> initiallyApplied,
  required Set<String> partiallyApplied,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    // Cf. `showLabelsSheet` : la feuille doit couvrir la barre d'onglets.
    useRootNavigator: true,
    builder: (_) => _LabelPickerSheet(
      contactIds: contactIds,
      initiallyApplied: initiallyApplied,
      partiallyApplied: partiallyApplied,
    ),
  );
}

class _LabelPickerSheet extends ConsumerStatefulWidget {
  const _LabelPickerSheet({
    required this.contactIds,
    required this.initiallyApplied,
    required this.partiallyApplied,
  });

  final Set<String> contactIds;
  final Set<String> initiallyApplied;
  final Set<String> partiallyApplied;

  @override
  ConsumerState<_LabelPickerSheet> createState() => _LabelPickerSheetState();
}

class _LabelPickerSheetState extends ConsumerState<_LabelPickerSheet> {
  late final Set<String> _checked = {...widget.initiallyApplied};
  late final Set<String> _partial = {...widget.partiallyApplied};

  @override
  Widget build(BuildContext context) {
    final labels = ref.watch(labelListProvider).value ?? const <LabelDto>[];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Étiquettes', style: TextStyle(fontSize: 20)),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final label in labels)
                    CheckboxListTile(
                      value: _partial.contains(label.id) ? null : _checked.contains(label.id),
                      tristate: _partial.contains(label.id),
                      title: Text(label.name),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (value) => setState(() {
                        _partial.remove(label.id);
                        if (value ?? false) {
                          _checked.add(label.id);
                        } else {
                          _checked.remove(label.id);
                        }
                      }),
                    ),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Créer une étiquette'),
                    onTap: () async {
                      final id = await createLabelDialog(context, ref);
                      if (id != null) setState(() => _checked.add(id));
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(onPressed: _apply, child: const Text('Appliquer')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _apply() async {
    final navigator = Navigator.of(context);
    final apply = ref.read(labelsServiceProvider).apply;
    final labels = ref.read(labelListProvider).value ?? const <LabelDto>[];

    for (final label in labels) {
      // Une case restée partielle n'a pas été touchée : on n'y retouche pas non
      // plus, sinon valider la feuille modifierait des fiches sans le dire.
      if (_partial.contains(label.id)) continue;
      await apply.execute(widget.contactIds, label.id, apply: _checked.contains(label.id));
    }
    navigator.pop();
  }
}
