import 'package:contacts/core/domain/model/app_settings.dart';

/// Port de persistance des réglages d'affichage.
abstract interface class SettingsRepository {
  Future<AppSettings> read();

  Future<void> write(AppSettings settings);
}
