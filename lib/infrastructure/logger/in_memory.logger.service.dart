import 'package:contacts/core/domain/model/log_level.dart';
import 'package:contacts/core/domain/services/logger.service.dart';

/// [LoggerService] de test : retient chaque entrée dans une liste, sur le modèle
/// des doublures `InMemory*` du reste de `lib/infrastructure/`.
///
/// Pas câblé en production ; les tests qui veulent vérifier un journal le
/// construisent eux-mêmes :
///
/// ```dart
/// final logs = InMemoryLoggerService();
/// await useCase.execute(...);
/// expect(logs.records.last.message, 'contact.saved');
/// ```
class InMemoryLoggerService implements LoggerService {
  final List<LoggedRecord> records = [];

  /// Les messages seuls, dans l'ordre — le raccourci des assertions courantes.
  List<String> get messages => [for (final r in records) r.message];

  @override
  Future<void> log(
    LogLevel level,
    String message, {
    Map<String, Object?> attributes = const {},
    Object? error,
    StackTrace? stack,
  }) async {
    records.add(
      LoggedRecord(
        level: level,
        message: message,
        attributes: Map.unmodifiable(attributes),
        error: error,
        stack: stack,
      ),
    );
  }

  @override
  Future<void> flush() async {}

  /// Oublie tout. Utile entre deux cas de test.
  void clear() => records.clear();
}

/// Une entrée retenue par [InMemoryLoggerService].
class LoggedRecord {
  const LoggedRecord({
    required this.level,
    required this.message,
    required this.attributes,
    this.error,
    this.stack,
  });

  final LogLevel level;
  final String message;
  final Map<String, Object?> attributes;
  final Object? error;
  final StackTrace? stack;
}
