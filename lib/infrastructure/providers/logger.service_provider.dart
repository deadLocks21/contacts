import 'dart:io' show Platform;

import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:contacts/core/domain/model/log_level.dart';
import 'package:contacts/core/domain/services/logger.service.dart';
import 'package:contacts/infrastructure/logger/composite.logger.service.dart';
import 'package:contacts/infrastructure/logger/console.logger.service.dart';
import 'package:contacts/infrastructure/logger/signoz.logger.service.dart';
import 'package:contacts/infrastructure/observability/route_tracker.dart';
import 'package:contacts/infrastructure/providers/infra_providers.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logger.service_provider.g.dart';

/// Point d'entrée OTLP de Signoz, fixé à la compilation — par exemple
/// `https://ingest.eu.signoz.cloud:443/v1/logs`. Vide : Signoz est débranché et
/// tout reste dans la console.
///
/// ```bash
/// flutter run --dart-define=SIGNOZ_INGEST_URL=https://ingest.eu.signoz.cloud:443/v1/logs
/// ```
const _signozEndpoint = String.fromEnvironment('SIGNOZ_INGEST_URL');

/// Clé d'ingestion Signoz Cloud, envoyée en `signoz-access-token`. Vide pour
/// une instance auto-hébergée sans authentification.
const _signozKey = String.fromEnvironment('SIGNOZ_INGESTION_KEY');

/// Force la valeur de `deployment.environment`. Par défaut : `production` en
/// build de release, `development` sinon.
const _environmentOverride = String.fromEnvironment('SIGNOZ_ENV');

/// Version portée par l'attribut `service.version`. Le sentinel `dev` rend
/// visible dans Signoz un build qu'on aurait oublié de renseigner.
const _appVersion = String.fromEnvironment('APP_VERSION', defaultValue: 'dev');

/// Écran courant, tenu à jour par le router — cf. [RouteTracker].
@Riverpod(keepAlive: true)
RouteTracker routeTracker(Ref ref) => RouteTracker();

/// Le [LoggerService] de l'app.
///
/// | Build   | SIGNOZ_INGEST_URL | Implémentation                              |
/// |---------|-------------------|---------------------------------------------|
/// | release | non               | [ConsoleLoggerService] (repli sans perte)   |
/// | release | oui               | [SignozLoggerService] seul                  |
/// | debug   | non               | [ConsoleLoggerService] seul                 |
/// | debug   | oui               | [CompositeLoggerService] : console + Signoz |
///
/// La dernière ligne est celle qui compte au quotidien : elle met sous les yeux
/// du développeur exactement ce qui part sur le réseau.
///
/// `keepAlive` parce que l'adaptateur Signoz tient une minuterie et un client
/// HTTP : les recréer à la demande n'aurait aucun sens, et chaque destruction
/// perdrait le tampon en cours.
@Riverpod(keepAlive: true)
LoggerService loggerService(Ref ref) {
  final hasSignoz = _signozEndpoint.isNotEmpty;
  final console = ConsoleLoggerService(
    prefix: hasSignoz && !kReleaseMode ? '[→signoz]' : null,
    // En développement, ce qui va mal doit se lire dans le terminal de
    // `flutter run` — cf. [ConsoleLoggerService.mirrorFrom].
    mirrorFrom: kReleaseMode ? null : LogLevel.warn,
  );
  if (!hasSignoz) return console;

  final signoz = SignozLoggerService(
    endpoint: _signozEndpoint,
    ingestionKey: _signozKey.isEmpty ? null : _signozKey,
    resourceAttributes: _resourceAttributes(
      usesDeviceContacts: ref.watch(useDeviceContactsProvider),
    ),
  );
  ref.onDispose(signoz.dispose);

  return kReleaseMode ? signoz : CompositeLoggerService([console, signoz]);
}

/// La façade que consomment `main()`, les cas d'usage et l'UI.
///
/// Le contexte dynamique est relu à **chaque** émission, jamais capturé : le
/// journal reste la même instance d'un bout à l'autre de la session — donc le
/// tampon Signoz aussi — tout en portant l'écran affiché à l'instant où la ligne
/// est écrite. C'est ce qui rend une erreur exploitable : on sait d'où elle
/// vient sans avoir à le déduire.
@Riverpod(keepAlive: true)
LoggerApplicationService logger(Ref ref) {
  final tracker = ref.watch(routeTrackerProvider);
  return LoggerApplicationService(
    ref.watch(loggerServiceProvider),
    resolveContext: () => <String, Object?>{'app.route': ?tracker.current},
  );
}

Map<String, Object?> _resourceAttributes({required bool usesDeviceContacts}) => {
  'service.name': 'contacts',
  'service.version': _appVersion,
  'deployment.environment': _environmentOverride.isNotEmpty
      ? _environmentOverride
      : (kReleaseMode ? 'production' : 'development'),
  'os.type': _osType(),
  // Le carnet simulé ne se comporte pas comme celui du système (identifiants,
  // permissions, notifications de changement) : sans cet attribut, deux
  // journaux très différents se mélangeraient dans les mêmes tableaux de bord.
  'contacts.backend': usesDeviceContacts ? 'device' : 'local',
};

String _osType() {
  // `Platform` n'existe pas sur le web. Le carnet ne vise pas le navigateur,
  // mais le repli coûte deux lignes.
  try {
    return Platform.operatingSystem;
  } catch (_) {
    return 'unknown';
  }
}
