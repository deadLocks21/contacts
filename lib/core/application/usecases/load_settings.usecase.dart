import 'package:contacts/core/domain/model/app_settings.dart';
import 'package:contacts/core/domain/services/settings.repository.dart';

/// Lit les réglages d'affichage (tri, format de nom, thème).
class LoadSettingsUseCase {
  const LoadSettingsUseCase(this._settings);

  final SettingsRepository _settings;

  Future<AppSettings> execute() => _settings.read();
}
