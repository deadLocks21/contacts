import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:contacts/core/domain/model/app_settings.dart';
import 'package:contacts/core/domain/services/settings.repository.dart';

/// Enregistre les réglages d'affichage.
class UpdateSettingsUseCase {
  const UpdateSettingsUseCase(this._settings, this._logger);

  final SettingsRepository _settings;
  final LoggerApplicationService _logger;

  Future<void> execute(AppSettings settings) async {
    await _settings.write(settings);
    // Un tri ou un format de nom inattendu explique bien des « ma liste a
    // changé toute seule » : la trace dit ce qui a été écrit, et quand.
    await _logger.info(
      'settings.updated',
      attrs: {
        'settings.sort_order': settings.sortOrder.name,
        'settings.name_format': settings.nameFormat.name,
        'settings.theme_mode': settings.themeMode.name,
      },
    );
  }
}
