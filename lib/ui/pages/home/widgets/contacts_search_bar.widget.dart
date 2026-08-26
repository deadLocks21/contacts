import 'package:contacts/ui/theme/app_colors.dart';
import 'package:contacts/ui/widgets/contact_avatar.widget.dart';
import 'package:flutter/material.dart';

/// La barre de recherche en pilule de l'écran d'accueil.
///
/// Ce n'est pas un champ de saisie : la frappe se fait sur l'écran de
/// recherche. Google fait de même — appuyer ici ouvre une page dédiée, ce qui
/// évite un clavier au-dessus d'une liste qui ne se filtre pas encore.
class ContactsSearchBar extends StatelessWidget {
  const ContactsSearchBar({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Material(
        color: colors.surfaceField,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          key: const Key('searchBar'),
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: SizedBox(
            height: 52,
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(Icons.search, color: colors.textMuted),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Rechercher des contacts',
                    style: TextStyle(color: colors.textMuted, fontSize: 16),
                  ),
                ),
                // L'avatar du compte : dans Google Contacts il ouvre le
                // sélecteur de compte, ici les paramètres — c'est le seul
                // réglage que l'app locale ait à proposer.
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ContactAvatar(initials: 'T', colorKey: 'mon compte', size: 36),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
