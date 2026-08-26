import 'package:contacts/core/application/dtos/label.dto.dart';
import 'package:contacts/ui/providers/contact_data_providers.dart';
import 'package:contacts/ui/router/app_router.dart';
import 'package:contacts/ui/theme/app_colors.dart';
import 'package:contacts/ui/widgets/label_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Le tiroir de navigation : les vues du carnet, les étiquettes, puis la
/// corbeille et les réglages.
class ContactsDrawer extends ConsumerWidget {
  const ContactsDrawer({super.key, this.selectedLabelId, this.starredSelected = false});

  /// Étiquette actuellement affichée, pour la mettre en évidence.
  final String? selectedLabelId;

  /// Vrai quand la vue « Favoris » est à l'écran.
  final bool starredSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final labels = ref.watch(labelListProvider).value ?? const <LabelDto>[];
    final isRoot = selectedLabelId == null && !starredSelected;

    return Drawer(
      backgroundColor: colors.surfaceAlt,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 16, 20),
              child: Text(
                'Contacts',
                style: TextStyle(
                  fontSize: 22,
                  color: colors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            _DrawerTile(
              icon: Icons.person_outline,
              label: 'Contacts',
              selected: isRoot,
              onTap: () {
                Navigator.of(context).pop();
                if (!isRoot) context.go(AppRoutes.contacts);
              },
            ),
            _DrawerTile(
              icon: Icons.star_outline,
              label: 'Favoris',
              selected: starredSelected,
              onTap: () {
                Navigator.of(context).pop();
                if (!starredSelected) context.push(AppRoutes.favorites);
              },
            ),
            const Divider(indent: 28, endIndent: 28, height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 4, 16, 8),
              child: Text(
                'Étiquettes',
                style: TextStyle(fontSize: 14, color: colors.textMuted),
              ),
            ),
            for (final label in labels)
              _DrawerTile(
                icon: Icons.label_outline,
                label: label.name,
                trailing: label.contactCount == 0 ? null : '${label.contactCount}',
                selected: label.id == selectedLabelId,
                onTap: () {
                  Navigator.of(context).pop();
                  if (label.id != selectedLabelId) context.push(AppRoutes.label(label.id));
                },
              ),
            _DrawerTile(
              icon: Icons.add,
              label: 'Créer une étiquette',
              onTap: () async {
                Navigator.of(context).pop();
                await createLabelDialog(context, ref);
              },
            ),
            const Divider(indent: 28, endIndent: 28, height: 24),
            _DrawerTile(
              icon: Icons.delete_outline,
              label: 'Corbeille',
              onTap: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.trash);
              },
            ),
            _DrawerTile(
              icon: Icons.settings_outlined,
              label: 'Paramètres',
              onTap: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.settings);
              },
            ),
            _DrawerTile(
              icon: Icons.help_outline,
              label: 'Aide et commentaires',
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Aide indisponible dans cette version.')),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

/// Ligne du tiroir : pilule pleine quand elle est active, comme chez Google.
class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? colors.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 22, color: selected ? colors.onAccentSoft : colors.textMuted),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? colors.onAccentSoft : colors.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null)
                  Text(
                    trailing!,
                    style: TextStyle(fontSize: 13, color: colors.textMuted),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
