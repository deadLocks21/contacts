import 'dart:async';

import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:flutter/foundation.dart';

/// Dirige vers le journal les erreurs que personne n'a rattrapées.
///
/// Deux crochets couvrent l'essentiel de ce qui casse côté Dart :
///
/// - [FlutterError.onError] — les erreurs synchrones du framework (construction
///   d'un widget, mise en page, rendu, assertions).
/// - [PlatformDispatcher.onError] — les erreurs asynchrones qui ont échappé à
///   tous les `Future`, `Stream` et zones au-dessus d'elles, y compris un
///   `Future` en erreur que personne n'attend.
///
/// Ce que **ni l'un ni l'autre** n'attrape :
///
/// - Les plantages natifs (Swift/Obj-C sur iOS, JVM sur Android) : ils tuent
///   l'isolat Dart avant que l'un ou l'autre ne s'exécute. Il faudrait un
///   Crashlytics ou un Sentry, qui posent des gestionnaires natifs.
/// - Les erreurs d'un isolat secondaire, qui a sa propre boucle d'événements.
///   L'app n'en lance aucun aujourd'hui (`compute`, `Isolate.run`).
/// - Ce qui casse avant cet appel, dans les premières lignes de `main()`.
///
/// Renvoie de quoi rétablir les gestionnaires précédents — les tests s'en
/// servent pour ne pas se contaminer entre eux.
void Function() installErrorHandlers(LoggerApplicationService logger) {
  final previousFlutterOnError = FlutterError.onError;
  final previousPlatformOnError = PlatformDispatcher.instance.onError;

  FlutterError.onError = (details) {
    unawaited(
      logger.error(
        'flutter.error',
        attrs: {
          'flutter.library': ?details.library,
          'flutter.context': ?details.context?.toString(),
        },
        error: details.exception,
        stack: details.stack,
      ),
    );
    // On garde le comportement par défaut (écran rouge en debug, trace dans la
    // console ailleurs) : journaliser ne doit pas masquer l'erreur.
    previousFlutterOnError?.call(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(logger.error('dart.uncaught', error: error, stack: stack));
    // `true` : l'erreur est tenue pour traitée et l'app continue de tourner au
    // lieu de remonter à la plateforme, qui la tuerait. Elle reste visible en
    // développement — le journal de console recopie les erreurs sur la sortie
    // standard, faute de quoi ce `true` les ferait disparaître du terminal.
    return true;
  };

  return () {
    FlutterError.onError = previousFlutterOnError;
    PlatformDispatcher.instance.onError = previousPlatformOnError;
  };
}
