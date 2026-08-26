import 'package:contacts/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Sélecteur de libellé d'un champ (« Mobile », « Domicile »…), posé à droite
/// de la saisie comme dans le formulaire Google.
///
/// Choisir « Personnalisé » demande aussitôt l'intitulé : un libellé
/// personnalisé vide n'aurait aucun sens et réafficherait « Personnalisé ».
class FieldTypeButton<T> extends StatelessWidget {
  const FieldTypeButton({
    super.key,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.displayLabel,
    required this.onChanged,
    required this.isCustom,
    required this.onCustomLabel,
  });

  final T value;
  final List<T> values;
  final String Function(T) labelOf;

  /// Libellé affiché — l'intitulé personnalisé quand il y en a un.
  final String displayLabel;

  final ValueChanged<T> onChanged;
  final bool Function(T) isCustom;
  final Future<String?> Function() onCustomLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return PopupMenuButton<T>(
      tooltip: 'Choisir un libellé',
      onSelected: (selected) async {
        if (isCustom(selected)) {
          final label = await onCustomLabel();
          if (label == null) return;
        }
        onChanged(selected);
      },
      itemBuilder: (_) => [
        for (final v in values) PopupMenuItem(value: v, child: Text(labelOf(v))),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 96),
              child: Text(
                displayLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: colors.textMuted),
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 20, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}
