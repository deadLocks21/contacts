import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:contacts/core/domain/model/log_level.dart';
import 'package:contacts/infrastructure/logger/in_memory.logger.service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemoryLoggerService sink;

  setUp(() => sink = InMemoryLoggerService());

  test('chaque niveau porte sa gravité', () async {
    final logger = LoggerApplicationService(sink);

    await logger.debug('a');
    await logger.info('b');
    await logger.warn('c');
    await logger.error('d');

    expect(
      [for (final r in sink.records) r.level],
      [LogLevel.debug, LogLevel.info, LogLevel.warn, LogLevel.error],
    );
  });

  test('fusionne contexte dynamique, contexte statique et attributs d\'appel', () async {
    final logger = LoggerApplicationService(
      sink,
      resolveContext: () => {'app.route': '/organiser', 'source': 'dynamique'},
    ).withContext({'operation': 'import', 'source': 'statique'});

    await logger.info('vcard.imported', attrs: {'source': 'appel', 'contacts.count': 3});

    expect(sink.records.single.attributes, {
      'app.route': '/organiser',
      'operation': 'import',
      // Le plus précis gagne : appel > statique > dynamique.
      'source': 'appel',
      'contacts.count': 3,
    });
  });

  test('le contexte dynamique est relu à chaque émission', () async {
    var route = '/';
    final logger = LoggerApplicationService(sink, resolveContext: () => {'app.route': route});

    await logger.info('app.route');
    route = '/corbeille';
    await logger.info('app.route');

    expect([for (final r in sink.records) r.attributes['app.route']], ['/', '/corbeille']);
  });

  test('withContext n\'altère pas la façade d\'origine', () async {
    final base = LoggerApplicationService(sink);
    final scoped = base.withContext({'operation': 'merge'});

    await scoped.info('contacts.merged');
    await base.info('app.started');

    expect(sink.records.first.attributes, {'operation': 'merge'});
    expect(sink.records.last.attributes, isEmpty);
  });

  test('un résolveur qui lève ne fait pas disparaître la ligne', () async {
    final logger = LoggerApplicationService(
      sink,
      resolveContext: () => throw StateError('provider détruit'),
    );

    await logger.error('dart.uncaught', attrs: {'contact.id': '42'});

    // L'identité manque, l'enregistrement est là : c'est le bon compromis —
    // une erreur perdue coûte plus cher qu'une erreur sans contexte.
    expect(sink.records.single.message, 'dart.uncaught');
    expect(sink.records.single.attributes, {'contact.id': '42'});
  });

  test('transmet erreur et pile telles quelles', () async {
    final logger = LoggerApplicationService(sink);
    final stack = StackTrace.current;

    await logger.error('contact.save.failed', error: const FormatException(), stack: stack);

    expect(sink.records.single.error, isA<FormatException>());
    expect(sink.records.single.stack, same(stack));
  });
}
