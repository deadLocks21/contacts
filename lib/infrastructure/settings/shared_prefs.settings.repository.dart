import 'package:contacts/core/domain/model/app_settings.dart';
import 'package:contacts/core/domain/model/app_theme_mode.dart';
import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/core/domain/services/settings.repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Réglages d'affichage dans `shared_preferences` — trois valeurs scalaires,
/// aucune raison de les mettre en base.
class SharedPreferencesSettingsRepository implements SettingsRepository {
  static const _sortOrderKey = 'contacts.sort_order';
  static const _nameFormatKey = 'contacts.name_format';
  static const _themeModeKey = 'contacts.theme_mode';

  @override
  Future<AppSettings> read() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      sortOrder: ContactSortOrder.fromWire(prefs.getString(_sortOrderKey)),
      nameFormat: NameFormat.fromWire(prefs.getString(_nameFormatKey)),
      themeMode: AppThemeMode.fromWire(prefs.getString(_themeModeKey)),
    );
  }

  @override
  Future<void> write(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sortOrderKey, settings.sortOrder.wire);
    await prefs.setString(_nameFormatKey, settings.nameFormat.wire);
    await prefs.setString(_themeModeKey, settings.themeMode.wire);
  }
}

/// Réglages en mémoire — tests, et démarrage tant que le disque n'a pas répondu.
class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository([this._settings = AppSettings.defaults]);

  AppSettings _settings;

  @override
  Future<AppSettings> read() async => _settings;

  @override
  Future<void> write(AppSettings settings) async => _settings = settings;
}
