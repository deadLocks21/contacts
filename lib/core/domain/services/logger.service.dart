import 'package:contacts/core/domain/model/log_level.dart';

/// Port du journal applicatif.
///
/// Les implémentations vivent dans `lib/infrastructure/logger/` :
///
/// - [ConsoleLoggerService]   — écrit dans la console de développement.
/// - [SignozLoggerService]    — expédie les enregistrements à Signoz (OTLP/HTTP).
/// - [CompositeLoggerService] — diffuse aux deux à la fois, pour voir en local
///   exactement ce qui part sur le réseau.
/// - [InMemoryLoggerService]  — retient tout en mémoire, pour les tests.
///
/// Le contrat tient en une méthode : un puits asynchrone. Le confort d'écriture
/// (`info`, `error`, attributs de contexte automatiques) est l'affaire de la
/// couche application ([LoggerApplicationService]), pour que ce port ne bouge
/// pas quand elle évolue.
///
/// Les `attributes` sont des paires clé/valeur libres attachées à
/// l'enregistrement. Les valeurs doivent être des primitives sérialisables —
/// `String`, `num`, `bool` ou `null` ; le reste est converti par `toString()`.
///
/// Une implémentation **ne doit jamais lever** : un journal en panne dégrade en
/// silence, il ne fait pas tomber l'app avec lui.
abstract interface class LoggerService {
  /// Enregistre une entrée.
  ///
  /// [message] est le résumé lisible. Court et stable de préférence (bon :
  /// `contact.saved` ; mauvais : `Fiche de Jean Martin enregistrée à 10:42`) —
  /// les valeurs variables ont leur place dans [attributes], qui sont indexés.
  ///
  /// [error] et [stack] accompagnent les niveaux [LogLevel.warn] et
  /// [LogLevel.error] : type de l'exception et pile d'appels partent alors avec
  /// le message.
  Future<void> log(
    LogLevel level,
    String message, {
    Map<String, Object?> attributes,
    Object? error,
    StackTrace? stack,
  });

  /// Vide le tampon en attente. Appelé quand l'app passe en arrière-plan, pour
  /// que les dernières secondes ne soient pas perdues. Sans effet pour les
  /// implémentations qui n'accumulent rien.
  Future<void> flush();
}
