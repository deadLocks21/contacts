import 'package:contacts/core/domain/model/log_level.dart';
import 'package:contacts/core/domain/services/logger.service.dart';
import 'package:contacts/infrastructure/logger/composite.logger.service.dart';
import 'package:contacts/infrastructure/logger/in_memory.logger.service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Adaptateur qui refuse tout, pour vérifier qu'il n'entraîne pas les autres.
class _BrokenLoggerService implements LoggerService {
  var flushed = false;

  @override
  Future<void> log(
    LogLevel level,
    String message, {
    Map<String, Object?> attributes = const {},
    Object? error,
    StackTrace? stack,
  }) async => throw StateError('adaptateur en panne');

  @override
  Future<void> flush() async {
    flushed = true;
    throw StateError('adaptateur en panne');
  }
}

void main() {
  test('diffuse à tous les enfants', () async {
    final first = InMemoryLoggerService();
    final second = InMemoryLoggerService();

    await CompositeLoggerService([
      first,
      second,
    ]).log(LogLevel.info, 'app.started', attributes: {'store': 'sqflite'});

    expect(first.messages, ['app.started']);
    expect(second.messages, ['app.started']);
    expect(second.records.single.attributes, {'store': 'sqflite'});
  });

  test('un enfant en panne ne fait pas taire les autres', () async {
    final broken = _BrokenLoggerService();
    final healthy = InMemoryLoggerService();
    final composite = CompositeLoggerService([broken, healthy]);

    await expectLater(composite.log(LogLevel.error, 'dart.uncaught'), completes);
    await expectLater(composite.flush(), completes);

    expect(healthy.messages, ['dart.uncaught']);
    expect(broken.flushed, isTrue);
  });
}
