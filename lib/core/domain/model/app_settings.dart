import 'package:contacts/core/domain/model/app_theme_mode.dart';
import 'package:contacts/core/domain/model/enums.dart';

/// Réglages d'affichage du carnet — l'écran « Paramètres » de Google Contacts.
class AppSettings {
  /// Trier la liste par prénom ou par nom de famille.
  final ContactSortOrder sortOrder;

  /// Afficher « Jean Martin » ou « Martin, Jean ».
  final NameFormat nameFormat;

  final AppThemeMode themeMode;

  const AppSettings({
    this.sortOrder = ContactSortOrder.prenom,
    this.nameFormat = NameFormat.prenomNom,
    this.themeMode = AppThemeMode.systeme,
  });

  static const defaults = AppSettings();

  AppSettings copyWith({
    ContactSortOrder? sortOrder,
    NameFormat? nameFormat,
    AppThemeMode? themeMode,
  }) => AppSettings(
    sortOrder: sortOrder ?? this.sortOrder,
    nameFormat: nameFormat ?? this.nameFormat,
    themeMode: themeMode ?? this.themeMode,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          sortOrder == other.sortOrder &&
          nameFormat == other.nameFormat &&
          themeMode == other.themeMode;

  @override
  int get hashCode => Object.hash(sortOrder, nameFormat, themeMode);
}
