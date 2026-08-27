// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logger.service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Écran courant, tenu à jour par le router — cf. [RouteTracker].

@ProviderFor(routeTracker)
final routeTrackerProvider = RouteTrackerProvider._();

/// Écran courant, tenu à jour par le router — cf. [RouteTracker].

final class RouteTrackerProvider
    extends $FunctionalProvider<RouteTracker, RouteTracker, RouteTracker>
    with $Provider<RouteTracker> {
  /// Écran courant, tenu à jour par le router — cf. [RouteTracker].
  RouteTrackerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routeTrackerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routeTrackerHash();

  @$internal
  @override
  $ProviderElement<RouteTracker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RouteTracker create(Ref ref) {
    return routeTracker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RouteTracker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RouteTracker>(value),
    );
  }
}

String _$routeTrackerHash() => r'5d092549af32e748b32b49690ddb7554b58cd7c8';

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

@ProviderFor(loggerService)
final loggerServiceProvider = LoggerServiceProvider._();

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

final class LoggerServiceProvider
    extends $FunctionalProvider<LoggerService, LoggerService, LoggerService>
    with $Provider<LoggerService> {
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
  LoggerServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loggerServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loggerServiceHash();

  @$internal
  @override
  $ProviderElement<LoggerService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoggerService create(Ref ref) {
    return loggerService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoggerService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoggerService>(value),
    );
  }
}

String _$loggerServiceHash() => r'f41c76cd26a98d4978458b83aee2883389921320';

/// La façade que consomment `main()`, les cas d'usage et l'UI.
///
/// Le contexte dynamique est relu à **chaque** émission, jamais capturé : le
/// journal reste la même instance d'un bout à l'autre de la session — donc le
/// tampon Signoz aussi — tout en portant l'écran affiché à l'instant où la ligne
/// est écrite. C'est ce qui rend une erreur exploitable : on sait d'où elle
/// vient sans avoir à le déduire.

@ProviderFor(logger)
final loggerProvider = LoggerProvider._();

/// La façade que consomment `main()`, les cas d'usage et l'UI.
///
/// Le contexte dynamique est relu à **chaque** émission, jamais capturé : le
/// journal reste la même instance d'un bout à l'autre de la session — donc le
/// tampon Signoz aussi — tout en portant l'écran affiché à l'instant où la ligne
/// est écrite. C'est ce qui rend une erreur exploitable : on sait d'où elle
/// vient sans avoir à le déduire.

final class LoggerProvider
    extends
        $FunctionalProvider<
          LoggerApplicationService,
          LoggerApplicationService,
          LoggerApplicationService
        >
    with $Provider<LoggerApplicationService> {
  /// La façade que consomment `main()`, les cas d'usage et l'UI.
  ///
  /// Le contexte dynamique est relu à **chaque** émission, jamais capturé : le
  /// journal reste la même instance d'un bout à l'autre de la session — donc le
  /// tampon Signoz aussi — tout en portant l'écran affiché à l'instant où la ligne
  /// est écrite. C'est ce qui rend une erreur exploitable : on sait d'où elle
  /// vient sans avoir à le déduire.
  LoggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loggerHash();

  @$internal
  @override
  $ProviderElement<LoggerApplicationService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoggerApplicationService create(Ref ref) {
    return logger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoggerApplicationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoggerApplicationService>(value),
    );
  }
}

String _$loggerHash() => r'9b72eaa861d432ea82804eae1f8828ae492dba3b';
