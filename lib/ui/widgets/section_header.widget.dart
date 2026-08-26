import 'package:contacts/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// En-tête d'une tranche de la liste : la lettre de l'index, ou « Favoris ».
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      color: colors.background,
      padding: const EdgeInsets.fromLTRB(72, 16, 16, 8),
      child: Text(
        label,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textMuted),
      ),
    );
  }
}
