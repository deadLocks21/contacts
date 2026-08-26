import 'package:contacts/core/application/dtos/contact_detail.dto.dart';
import 'package:contacts/ui/theme/app_colors.dart';
import 'package:contacts/ui/utils/contact_actions.dart';
import 'package:contacts/ui/widgets/contact_avatar.widget.dart';
import 'package:flutter/material.dart';

/// Haut de la fiche : grande pastille, nom, poste et société, puis la rangée
/// d'actions rapides (appeler, message, vidéo, e-mail).
///
/// Une action sans donnée derrière elle est **grisée** plutôt que masquée :
/// la rangée garde la même forme d'une fiche à l'autre, et l'absence de
/// numéro se lit d'un coup d'œil.
class ContactHeader extends StatelessWidget {
  const ContactHeader({super.key, required this.contact});

  final ContactDetailDto contact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final phone = contact.primaryPhone;
    final email = contact.primaryEmail;
    final name = contact.displayName.isEmpty ? '(Sans nom)' : contact.displayName;

    return Column(
      children: [
        const SizedBox(height: 8),
        ContactAvatar(
          initials: contact.initials,
          colorKey: contact.displayName,
          photo: contact.photo,
          size: 112,
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, color: colors.textPrimary),
          ),
        ),
        if (contact.nickname != null) ...[
          const SizedBox(height: 4),
          Text('« ${contact.nickname} »', style: TextStyle(color: colors.textMuted)),
        ],
        if (contact.subtitle.isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              contact.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: colors.textMuted),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _QuickAction(
              icon: Icons.call,
              label: 'Appeler',
              onTap: phone == null ? null : () => dial(phone),
            ),
            _QuickAction(
              icon: Icons.chat_bubble_outline,
              label: 'Message',
              onTap: phone == null ? null : () => sendSms(phone),
            ),
            _QuickAction(
              icon: Icons.videocam_outlined,
              label: 'Vidéo',
              onTap: phone == null ? null : () => dial(phone),
            ),
            _QuickAction(
              icon: Icons.mail_outline,
              label: 'E-mail',
              onTap: email == null ? null : () => sendEmail(email),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final enabled = onTap != null;
    final foreground = enabled ? colors.onAccentSoft : colors.textMuted.withValues(alpha: 0.5);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Material(
            color: enabled ? colors.accentSoft : colors.surfaceField,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: SizedBox(
                width: 72,
                height: 48,
                child: Icon(icon, size: 22, color: foreground),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 12, color: foreground)),
        ],
      ),
    );
  }
}
