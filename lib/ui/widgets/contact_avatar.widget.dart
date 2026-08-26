import 'dart:io';

import 'package:contacts/core/application/services/avatar_color.service.dart';
import 'package:contacts/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Pastille d'un contact : sa photo, ou ses initiales sur fond coloré.
///
/// La couleur est dérivée du nom (cf. `AvatarColor`) et non tirée au sort :
/// le même contact garde la sienne d'un écran et d'une session à l'autre.
///
/// En sélection multiple, la pastille se retourne en coche bleue — c'est ce
/// que fait Google Contacts, plutôt que d'ajouter une case à cocher.
class ContactAvatar extends StatelessWidget {
  const ContactAvatar({
    super.key,
    required this.initials,
    required this.colorKey,
    this.photoPath,
    this.size = 40,
    this.selected = false,
  });

  final String initials;

  /// Texte dont on dérive la couleur — le nom affiché du contact.
  final String colorKey;

  final String? photoPath;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (selected) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle),
        child: Icon(Icons.check, color: colors.onAccent, size: size * 0.55),
      );
    }

    // Une photo dont le fichier a disparu (restauration partielle, nettoyage
    // système) ne doit pas laisser un trou : on retombe sur les initiales.
    final photo = photoPath;
    if (photo != null && photo.isNotEmpty && File(photo).existsSync()) {
      return ClipOval(
        child: Image.file(
          File(photo),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _initialsCircle(colors),
        ),
      );
    }
    return _initialsCircle(colors);
  }

  Widget _initialsCircle(AppColors colors) {
    if (initials.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: colors.surfaceField, shape: BoxShape.circle),
        child: Icon(Icons.person, color: colors.textMuted, size: size * 0.6),
      );
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.avatar(AvatarColor.indexFor(colorKey)),
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * (initials.length > 1 ? 0.36 : 0.44),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
