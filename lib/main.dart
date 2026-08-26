import 'package:contacts/core/domain/model/app_theme_mode.dart';
import 'package:contacts/infrastructure/persistence/contacts_database.dart';
import 'package:contacts/infrastructure/providers/bootstrap_providers.dart';
import 'package:contacts/infrastructure/providers/infra_providers.dart';
import 'package:contacts/infrastructure/providers/settings_providers.dart';
import 'package:contacts/ui/router/app_router.dart';
import 'package:contacts/ui/theme/app_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // La base sqflite devient le store local ; en cas d'échec (disque plein,
  // base corrompue) on reste sur l'implémentation mémoire plutôt que de
  // refuser de démarrer — le carnet se rechargera vide, mais l'app s'ouvre et
  // reste utilisable.
  ProviderContainer container;
  try {
    final database = await openContactsDatabase();
    container = ProviderContainer(
      overrides: [
        localRecordStoreProvider.overrideWithValue(SqfliteLocalRecordStore(database)),
      ],
    );
  } catch (_) {
    container = ProviderContainer();
  }

  runApp(UncontrolledProviderScope(container: container, child: const ContactsApp()));
}

/// Locale unique : français (France) — sélecteurs de date en français, lundi
/// en premier jour de semaine.
const _appLocale = Locale('fr', 'FR');

const _localizationsDelegates = <LocalizationsDelegate<dynamic>>[
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

class ContactsApp extends ConsumerWidget {
  const ContactsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(bootstrapProvider);
    final themeMode = ref.watch(currentSettingsProvider).themeMode;

    final light = AppThemeData.buildLightTheme();
    final dark = AppThemeData.buildDarkTheme();

    return bootstrap.when(
      loading: () => _shell(
        light,
        dark,
        AppThemeMode.systeme,
        const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (error, _) => _shell(
        light,
        dark,
        AppThemeMode.systeme,
        Scaffold(body: Center(child: Text('Erreur de démarrage : $error'))),
      ),
      data: (_) => MaterialApp.router(
        title: 'Contacts',
        theme: light,
        darkTheme: dark,
        themeMode: AppThemeData.toFlutterThemeMode(themeMode),
        locale: _appLocale,
        localizationsDelegates: _localizationsDelegates,
        supportedLocales: const [_appLocale],
        debugShowCheckedModeBanner: false,
        routerConfig: ref.watch(goRouterProvider),
      ),
    );
  }

  /// Coquille minimale pour les états d'amorçage — mêmes thèmes que l'app, pour
  /// qu'il n'y ait pas de saut visuel une fois le carnet chargé.
  Widget _shell(ThemeData light, ThemeData dark, AppThemeMode mode, Widget home) => MaterialApp(
    title: 'Contacts',
    theme: light,
    darkTheme: dark,
    themeMode: AppThemeData.toFlutterThemeMode(mode),
    locale: _appLocale,
    localizationsDelegates: _localizationsDelegates,
    supportedLocales: const [_appLocale],
    debugShowCheckedModeBanner: false,
    home: home,
  );
}
