import 'package:contacts/core/application/dtos/contact_summary.dto.dart';
import 'package:contacts/ui/theme/app_colors.dart';
import 'package:contacts/ui/widgets/contact_avatar.widget.dart';
import 'package:flutter/material.dart';

/// Une ligne de contact : pastille, nom, et sous-titre quand il y en a un.
///
/// [subtitleOverride] remplace « Poste, Société » là où la ligne dit autre
/// chose : le compte à rebours dans la corbeille, le motif dans les doublons.
class ContactTile extends StatelessWidget {
  const ContactTile({
    super.key,
    required this.contact,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.subtitleOverride,
    this.trailing,
    this.showStar = true,
    this.dense = false,
  });

  final ContactSummaryDto contact;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final String? subtitleOverride;
  final Widget? trailing;
  final bool showStar;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final subtitle = subtitleOverride ?? contact.subtitle;
    final name = contact.displayName.isEmpty ? '(Sans nom)' : contact.displayName;

    return Material(
      color: selected ? colors.selection : Colors.transparent,
      child: InkWell(
        key: Key('contactTile_${contact.id}'),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: dense ? 8 : 10),
          child: Row(
            children: [
              ContactAvatar(
                initials: contact.initials,
                colorKey: contact.displayName,
                photo: contact.photo,
                selected: selected,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: contact.displayName.isEmpty ? colors.textMuted : colors.textPrimary,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: colors.textMuted),
                      ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (showStar && contact.starred)
                Icon(Icons.star, size: 20, color: colors.star),
            ],
          ),
        ),
      ),
    );
  }
}
