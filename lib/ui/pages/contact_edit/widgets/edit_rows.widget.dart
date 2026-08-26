import 'package:contacts/core/application/dtos/contact_draft.dto.dart';
import 'package:contacts/ui/pages/contact_edit/widgets/field_type_button.widget.dart';
import 'package:contacts/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Ligne de saisie d'un champ libellé : la valeur, son libellé, et la croix
/// qui supprime la ligne.
class EditFieldRow<T> extends StatelessWidget {
  const EditFieldRow({
    super.key,
    required this.draft,
    required this.hint,
    required this.icon,
    required this.values,
    required this.labelOf,
    required this.displayLabel,
    required this.isCustom,
    required this.onChanged,
    required this.onRemove,
    required this.onCustomLabel,
    this.keyboardType,
    this.showIcon = true,
  });

  final FieldDraft<T> draft;
  final String hint;
  final IconData icon;
  final List<T> values;
  final String Function(T) labelOf;
  final String displayLabel;
  final bool Function(T) isCustom;

  /// Appelée après toute modification, pour que la page se redessine.
  final VoidCallback onChanged;

  final VoidCallback onRemove;
  final Future<String?> Function() onCustomLabel;
  final TextInputType? keyboardType;

  /// L'icône n'est portée que par la première ligne d'un groupe.
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            child: showIcon ? Icon(icon, size: 22, color: colors.textMuted) : null,
          ),
          Expanded(
            child: TextFormField(
              initialValue: draft.value,
              keyboardType: keyboardType,
              inputFormatters: keyboardType == TextInputType.phone
                  ? [FilteringTextInputFormatter.allow(RegExp(r'[\d +().\-]'))]
                  : null,
              decoration: InputDecoration(labelText: hint),
              onChanged: (value) {
                draft.value = value;
                onChanged();
              },
            ),
          ),
          FieldTypeButton<T>(
            value: draft.type,
            values: values,
            labelOf: labelOf,
            displayLabel: displayLabel,
            isCustom: isCustom,
            onCustomLabel: () async {
              final label = await onCustomLabel();
              if (label != null) draft.customLabel = label;
              return label;
            },
            onChanged: (value) {
              draft.type = value;
              onChanged();
            },
          ),
          IconButton(
            tooltip: 'Supprimer cette ligne',
            icon: Icon(Icons.close, size: 20, color: colors.textMuted),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

/// Bouton « Ajouter un numéro », « Ajouter une adresse e-mail »…
class AddFieldButton extends StatelessWidget {
  const AddFieldButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 0, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: onPressed,
          icon: Icon(Icons.add, size: 20, color: colors.accent),
          label: Text(label),
        ),
      ),
    );
  }
}
