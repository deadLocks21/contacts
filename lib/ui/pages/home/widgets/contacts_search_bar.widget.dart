import 'package:contacts/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// La barre de recherche en pilule de l'écran d'accueil.
///
/// Ce n'est pas un champ de saisie : la frappe se fait sur l'écran de
/// recherche. Google fait de même — appuyer ici ouvre une page dédiée, ce qui
/// évite un clavier au-dessus d'une liste qui ne se filtre pas encore.
class ContactsSearchBar extends StatelessWidget {
  const ContactsSearchBar({
    super.key,
    required this.hint,
    required this.onTap,
    this.onMenuPressed,
    this.leadingIcon = Icons.menu,
    this.trailing,
  });

  final String hint;
  final VoidCallback onTap;
  final VoidCallback? onMenuPressed;
  final IconData leadingIcon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: colors.surfaceField,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          key: const Key('searchBar'),
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: SizedBox(
            height: 48,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(leadingIcon, color: colors.textMuted),
                  tooltip: 'Menu de navigation',
                  onPressed: onMenuPressed ?? onTap,
                ),
                Expanded(
                  child: Text(hint, style: TextStyle(color: colors.textMuted, fontSize: 16)),
                ),
                if (trailing != null) trailing! else const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
