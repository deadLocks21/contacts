import 'package:contacts/core/application/dtos/contact_draft.dto.dart';
import 'package:contacts/core/application/services/date_label.service.dart';
import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/ui/pages/contact_edit/widgets/field_type_button.widget.dart';
import 'package:contacts/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Bloc de saisie d'une adresse postale : ses six champs, empilés.
class EditAddressRow extends StatelessWidget {
  const EditAddressRow({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.onRemove,
    required this.onCustomLabel,
    this.showIcon = true,
  });

  final AddressDraft draft;
  final VoidCallback onChanged;
  final VoidCallback onRemove;
  final Future<String?> Function() onCustomLabel;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: showIcon
                ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Icon(Icons.location_on_outlined, size: 22, color: colors.textMuted),
                  )
                : null,
          ),
          Expanded(
            child: Column(
              children: [
                _line('Rue', draft.street, (v) => draft.street = v),
                Row(
                  children: [
                    Expanded(child: _line('Code postal', draft.postcode, (v) => draft.postcode = v)),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: _line('Ville', draft.city, (v) => draft.city = v)),
                  ],
                ),
                _line('Région', draft.region, (v) => draft.region = v),
                _line('Pays', draft.country, (v) => draft.country = v),
                _line('Boîte postale', draft.poBox, (v) => draft.poBox = v),
              ],
            ),
          ),
          Column(
            children: [
              FieldTypeButton<AddressType>(
                value: draft.type,
                values: AddressType.values,
                labelOf: (t) => t.label,
                displayLabel: draft.type == AddressType.personnalise && draft.customLabel.isNotEmpty
                    ? draft.customLabel
                    : draft.type.label,
                isCustom: (t) => t == AddressType.personnalise,
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
                tooltip: 'Supprimer cette adresse',
                icon: Icon(Icons.close, size: 20, color: colors.textMuted),
                onPressed: onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value, ValueChanged<String> setter) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextFormField(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      onChanged: (v) {
        setter(v);
        onChanged();
      },
    ),
  );
}

/// Ligne de saisie d'une date importante. L'année reste facultative — Google
/// Contacts accepte « 14 février » tout court, et le sélecteur de date de
/// Flutter en impose une : on la retire après coup si l'utilisateur le demande.
class EditEventRow extends StatelessWidget {
  const EditEventRow({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.onRemove,
    required this.onCustomLabel,
    this.showIcon = true,
  });

  final EventDraft draft;
  final VoidCallback onChanged;
  final VoidCallback onRemove;
  final Future<String?> Function() onCustomLabel;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final filled = draft.month != null && draft.day != null;
    final text = filled
        ? DateLabel.eventDate(draft.day!, draft.month!, draft.year)
        : 'Choisir une date';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: showIcon ? Icon(Icons.cake_outlined, size: 22, color: colors.textMuted) : null,
          ),
          Expanded(
            child: InkWell(
              onTap: () => _pickDate(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: filled ? colors.textPrimary : colors.textMuted,
                  ),
                ),
              ),
            ),
          ),
          if (filled && draft.year != null)
            IconButton(
              tooltip: 'Retirer l\'année',
              icon: Icon(Icons.event_busy_outlined, size: 20, color: colors.textMuted),
              onPressed: () {
                draft.year = null;
                onChanged();
              },
            ),
          FieldTypeButton<EventType>(
            value: draft.type,
            values: EventType.values,
            labelOf: (t) => t.label,
            displayLabel: draft.type == EventType.personnalise && draft.customLabel.isNotEmpty
                ? draft.customLabel
                : draft.type.label,
            isCustom: (t) => t == EventType.personnalise,
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
            tooltip: 'Supprimer cette date',
            icon: Icon(Icons.close, size: 20, color: colors.textMuted),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initial = draft.month == null
        ? DateTime(now.year - 30, now.month, now.day)
        : DateTime(draft.year ?? now.year, draft.month!, draft.day!);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 10),
      helpText: 'Choisir une date',
    );
    if (picked == null) return;
    draft.year = picked.year;
    draft.month = picked.month;
    draft.day = picked.day;
    onChanged();
  }
}
