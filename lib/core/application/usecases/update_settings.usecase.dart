import 'package:contacts/core/domain/model/app_settings.dart';
import 'package:contacts/core/domain/services/settings.repository.dart';

/// Enregistre les réglages d'affichage.
class UpdateSettingsUseCase {
  const UpdateSettingsUseCase(this._settings);

  final SettingsRepository _settings;

  Future<void> execute(AppSettings settings) => _settings.write(settings);
}
