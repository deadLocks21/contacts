import 'dart:developer' as developer;

import 'package:contacts/core/domain/model/log_level.dart';
import 'package:contacts/core/domain/services/logger.service.dart';
import 'package:flutter/foundation.dart' show debugPrint;

/// [LoggerService] qui écrit dans la console de développement, via le `log()`
/// de `dart:developer`.
///
/// C'est le puits de tous les builds de développement, et la seconde branche du
/// [CompositeLoggerService] quand Signoz est configuré : le développeur voit
/// alors dans sa console exactement ce qui part sur le réseau.
///
/// Une ligne par enregistrement — `message clé=valeur clé=valeur` — suivie de la
/// pile d'appels s'il y en a une. De quoi filtrer au `grep`.
///
/// N'accumule rien : [flush] ne fait rien.
class ConsoleLoggerService implements LoggerService {
  const ConsoleLoggerService({this.prefix, this.name = 'contacts', this.mirrorFrom});

  /// Marqueur ajouté devant le message. Sert à distinguer les enregistrements
  /// qui partent **aussi** vers Signoz (`[→signoz]`).
  final String? prefix;

  /// Nom de journal `dart:developer` — la catégorie affichée par DevTools.
  final String name;

  /// Gravité à partir de laquelle la ligne est **aussi** recopiée sur la sortie
  /// standard. `null` : jamais.
  ///
  /// `developer.log` ne parle qu'au service VM : DevTools l'affiche, la console
  /// de `flutter run` non. Or `PlatformDispatcher.onError` rend `true` — Flutter
  /// n'imprime donc plus rien de son côté. Sans cette recopie, une erreur
  /// asynchrone non rattrapée disparaîtrait purement et simplement du terminal
  /// en développement : journalisée, mais invisible là où on la cherche.
  ///
  /// Réglée sur [LogLevel.warn] hors release : ce qui va mal se voit, le
  /// bavardage courant (`app.route`, `contact.saved`) reste dans DevTools.
  final LogLevel? mirrorFrom;

  @override
  Future<void> log(
    LogLevel level,
    String message, {
    Map<String, Object?> attributes = const {},
    Object? error,
    StackTrace? stack,
  }) async {
    final buffer = StringBuffer();
    if (prefix != null) buffer.write('$prefix ');
    buffer.write(message);
    if (attributes.isNotEmpty) {
      buffer.write(' ');
      buffer.writeAll(attributes.entries.map((e) => '${e.key}=${_format(e.value)}'), ' ');
    }
    final line = buffer.toString();
    developer.log(
      line,
      name: name,
      // `dart:developer` attend une échelle 0..2000, pas celle d'OpenTelemetry.
      level: level.otelSeverityNumber * 100,
      error: error,
      stackTrace: stack,
    );
    if (mirrorFrom case final threshold?
        when level.otelSeverityNumber >= threshold.otelSeverityNumber) {
      debugPrint('[$name] ${level.otelSeverityText} $line');
      if (error != null) debugPrint('[$name]   erreur : $error');
      if (stack?.toString() case final trace? when trace.isNotEmpty) {
        debugPrint('[$name]   ${trace.trimRight()}');
      }
    }
  }

  @override
  Future<void> flush() async {}

  String _format(Object? value) {
    if (value == null) return 'null';
    if (value is String) {
      // Guillemets seulement si la valeur contient une espace : la ligne reste
      // ainsi la plus facile possible à filtrer.
      return value.contains(RegExp(r'\s')) ? '"$value"' : value;
    }
    return value.toString();
  }
}
