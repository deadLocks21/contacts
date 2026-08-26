/// Thème choisi dans les réglages. `systeme` suit le réglage de l'appareil.
enum AppThemeMode {
  clair,
  sombre,
  systeme;

  String get wire => name;
  static AppThemeMode fromWire(String? w) =>
      AppThemeMode.values.where((e) => e.name == w).firstOrNull ?? AppThemeMode.systeme;

  String get label => switch (this) {
    AppThemeMode.clair => 'Clair',
    AppThemeMode.sombre => 'Sombre',
    AppThemeMode.systeme => 'Paramètres par défaut du système',
  };
}
