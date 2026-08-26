import 'package:contacts/core/application/usecases/load_settings.usecase.dart';
import 'package:contacts/core/application/usecases/update_settings.usecase.dart';

/// Les cas d'usage des réglages d'affichage.
class SettingsApplicationService {
  const SettingsApplicationService({required this.load, required this.update});

  final LoadSettingsUseCase load;
  final UpdateSettingsUseCase update;
}
