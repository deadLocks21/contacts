import 'package:contacts/core/application/dtos/contact_field.dto.dart';
import 'package:contacts/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Une famille de champs de la fiche (les téléphones, les e-mails…).
///
/// L'icône n'est portée que par la **première** ligne du groupe, les suivantes
/// s'alignant dessous : c'est la mise en page de Google Contacts, qui évite de
/// répéter la même icône trois fois pour trois numéros.
class ContactFieldRows extends StatelessWidget {
  const ContactFieldRows({
    super.key,
    required this.icon,
    required this.fields,
    this.onTap,
    this.trailingBuilder,
  });

  final IconData icon;
  final List<ContactFieldDto> fields;
  final void Function(ContactFieldDto field)? onTap;
  final Widget? Function(ContactFieldDto field)? trailingBuilder;

  @override
  Widget build(BuildContext context) {
    if (fields.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        for (var i = 0; i < fields.length; i++)
          _FieldRow(
            icon: i == 0 ? icon : null,
            field: fields[i],
            onTap: onTap == null ? null : () => onTap!(fields[i]),
            trailing: trailingBuilder?.call(fields[i]),
          ),
      ],
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.field, this.icon, this.onTap, this.trailing});

  final ContactFieldDto field;
  final IconData? icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              child: icon == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(icon, size: 22, color: colors.textMuted),
                    ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.value,
                    style: TextStyle(fontSize: 16, color: colors.textPrimary, height: 1.35),
                  ),
                  const SizedBox(height: 2),
                  Text(field.label, style: TextStyle(fontSize: 13, color: colors.textMuted)),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}

/// Intitulé d'un bloc de la fiche (« Coordonnées », « Étiquettes »).
class DetailSectionTitle extends StatelessWidget {
  const DetailSectionTitle(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      child: Text(
        label,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textMuted),
      ),
    );
  }
}
