import 'dart:async';

import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:contacts/core/domain/model/app_theme_mode.dart';
import 'package:contacts/infrastructure/observability/error_handlers.dart';
import 'package:contacts/infrastructure/observability/logging.provider_observer.dart';
import 'package:contacts/infrastructure/persistence/contacts_database.dart';
import 'package:contacts/infrastructure/providers/bootstrap_providers.dart';
import 'package:contacts/infrastructure/providers/infra_providers.dart';
import 'package:contacts/infrastructure/providers/logger.service_provider.dart';
import 'package:contacts/infrastructure/providers/settings_providers.dart';
import 'package:contacts/ui/router/app_router.dart';
import 'package:contacts/ui/router/route_journal.dart';
import 'package:contacts/ui/theme/app_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' show Database;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // La base sqflite devient le store local ; en cas d'échec (disque plein,
  // base corrompue) on reste sur l'implémentation mémoire plutôt que de
  // refuser de démarrer — le carnet se rechargera vide, mais l'app s'ouvre et
  // reste utilisable. L'échec est mis de côté le temps que le conteneur existe :
  // c'est lui qui porte le journal, et une corbeille qui disparaît sans un mot
  // est exactement le genre de panne qu'on ne veut pas découvrir par hasard.
  Database? database;
  Object? databaseError;
  StackTrace? databaseStack;
  try {
    database = await openContactsDatabase();
  } catch (e, st) {
    databaseError = e;
    databaseStack = st;
  }

  late final ProviderContainer container;
  container = ProviderContainer(
    observers: [LoggingProviderObserver(() => container.read(loggerProvider))],
    overrides: [
      if (database != null)
        localRecordStoreProvider.overrideWithValue(SqfliteLocalRecordStore(database)),
    ],
  );

  final logger = container.read(loggerProvider);
  installErrorHandlers(logger);
  _lifecycleFlush = _installLifecycleFlush(logger);

  if (databaseError != null) {
    unawaited(
      logger.error(
        'store.open_failed',
        attrs: {'store': 'memory'},
        error: databaseError,
        stack: databaseStack,
      ),
    );
  }
  unawaited(
    logger.info(
      'app.started',
      attrs: {
        'store': database != null ? 'sqflite' : 'memory',
        'contacts.backend': container.read(useDeviceContactsProvider) ? 'device' : 'local',
      },
    ),
  );

  // Le router est construit ici — et non au premier affichage — pour que le
  // journal connaisse l'écran courant dès la première ligne écrite.
  installRouteJournal(
    container.read(goRouterProvider),
    logger: logger,
    tracker: container.read(routeTrackerProvider),
  );

  runApp(UncontrolledProviderScope(container: container, child: const ContactsApp()));
}

/// Retenu pour la durée du processus : rien ne le relit, mais un
/// [AppLifecycleListener] se retire de [WidgetsBinding] dès qu'il est collecté —
/// et l'app cesserait alors d'expédier son journal en arrière-plan.
// ignore: unused_element
AppLifecycleListener? _lifecycleFlush;

/// Expédie le tampon du journal chaque fois que l'app quitte le premier plan,
/// et note le passage lui-même.
///
/// [SignozLoggerService] ne se vide sinon que sur sa minuterie de 10 s et ne
/// rejoue jamais un lot perdu : les dernières secondes avant que le système ne
/// suspende le processus partiraient avec lui. Or c'est précisément la fenêtre
/// qu'on veut lire — celle où l'utilisateur a fermé une app qui ne répondait
/// plus.
///
/// `detached` est au mieux : le système peut tuer le processus avant que la
/// requête aboutisse. Ce sont `hidden` et `paused` qui font le vrai travail,
/// puisqu'ils surviennent dès le passage en arrière-plan.
///
/// `app.lifecycle` sert accessoirement de repère : un trou dans la chronologie
/// est une app en arrière-plan, pas une app bloquée.
AppLifecycleListener _installLifecycleFlush(LoggerApplicationService logger) {
  void mark(String state, {required bool flush}) {
    unawaited(logger.info('app.lifecycle', attrs: {'app.state': state}));
    if (flush) unawaited(logger.flush());
  }

  return AppLifecycleListener(
    onHide: () => mark('hidden', flush: true),
    onPause: () => mark('paused', flush: true),
    onDetach: () => mark('detached', flush: true),
    // Pas de vidage forcé au retour : la minuterie s'en charge, et le processus
    // n'est pas sur le point de disparaître.
    onShow: () => mark('shown', flush: false),
    onResume: () => mark('resumed', flush: false),
  );
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
