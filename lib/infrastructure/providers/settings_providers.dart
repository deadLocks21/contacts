import 'package:contacts/core/domain/model/app_settings.dart';
import 'package:contacts/core/domain/model/app_theme_mode.dart';
import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/infrastructure/providers/service_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_providers.g.dart';

/// Réglages d'affichage, relus au démarrage puis tenus en mémoire.
///
/// Chaque modification est écrite **puis** publiée : l'écran de réglages
/// n'affiche pas une valeur qui ne serait pas encore sur le disque.
@Riverpod(keepAlive: true)
class SettingsController extends _$SettingsController {
  @override
  Future<AppSettings> build() => ref.watch(settingsServiceProvider).load.execute();

  Future<void> _update(AppSettings settings) async {
    await ref.read(settingsServiceProvider).update.execute(settings);
    state = AsyncData(settings);
  }

  Future<void> setSortOrder(ContactSortOrder order) async {
    final current = state.value ?? AppSettings.defaults;
    await _update(current.copyWith(sortOrder: order));
  }

  Future<void> setNameFormat(NameFormat format) async {
    final current = state.value ?? AppSettings.defaults;
    await _update(current.copyWith(nameFormat: format));
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final current = state.value ?? AppSettings.defaults;
    await _update(current.copyWith(themeMode: mode));
  }
}

/// Réglages courants, avec repli sur les valeurs par défaut tant que la
/// lecture n'a pas abouti — l'UI n'a ainsi jamais à gérer un état « pas encore
/// chargé » pour un simple critère de tri.
@riverpod
AppSettings currentSettings(Ref ref) =>
    ref.watch(settingsControllerProvider).value ?? AppSettings.defaults;
