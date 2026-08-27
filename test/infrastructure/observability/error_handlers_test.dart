import 'dart:async';

import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:contacts/core/domain/model/log_level.dart';
import 'package:contacts/infrastructure/logger/in_memory.logger.service.dart';
import 'package:contacts/infrastructure/observability/error_handlers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Le câblage des erreurs non rattrapées : le seul endroit d'où l'on apprend
/// qu'une app a cassé chez quelqu'un d'autre. Il n'est jamais exercé par les
/// autres tests — flutter_test pose ses propres gestionnaires — d'où celui-ci.
void main() {
  late InMemoryLoggerService sink;
  late void Function() restore;

  setUp(() {
    sink = InMemoryLoggerService();
    restore = installErrorHandlers(LoggerApplicationService(sink));
  });

  tearDown(() => restore());

  test('une erreur du framework est journalisée, sans être masquée', () {
    var presented = false;
    // `installErrorHandlers` a capturé le gestionnaire de flutter_test ; on
    // vérifie qu'il est toujours appelé après nous.
    final ours = FlutterError.onError!;
    FlutterError.onError = (details) {
      presented = true;
    };
    final chained = installErrorHandlers(LoggerApplicationService(sink));

    FlutterError.onError!(
      FlutterErrorDetails(
        exception: StateError('rendu impossible'),
        stack: StackTrace.current,
        library: 'widgets library',
        context: ErrorDescription('pendant la construction de HomePage'),
      ),
    );

    chained();
    FlutterError.onError = ours;

    final record = sink.records.single;
    expect(record.message, 'flutter.error');
    expect(record.level, LogLevel.error);
    expect(record.error, isA<StateError>());
    expect(record.attributes['flutter.library'], 'widgets library');
    expect(record.attributes['flutter.context'], contains('HomePage'));
    // L'écran rouge du mode debug reste : journaliser n'est pas rattraper.
    expect(presented, isTrue);
  });

  test('une erreur asynchrone non rattrapée est journalisée', () {
    final handled = PlatformDispatcher.instance.onError!(
      const FormatException('carnet illisible'),
      StackTrace.current,
    );

    expect(handled, isTrue, reason: 'l\'app continue de tourner');
    expect(sink.records.single.message, 'dart.uncaught');
    expect(sink.records.single.error, isA<FormatException>());
  });

  test('un Future en erreur que personne n\'attend finit par remonter', () async {
    // Le cas réel : un `unawaited` oublié, un `then` sans `onError`. Personne
    // ne le rattrape, la zone racine le remet à PlatformDispatcher.onError.
    final zoneErrors = <Object>[];
    await runZonedGuarded(() async {
      unawaited(Future<void>.error(StateError('écriture refusée')));
      await Future<void>.delayed(Duration.zero);
    }, (error, _) => zoneErrors.add(error));

    // Sous `runZonedGuarded`, c'est la zone qui reçoit l'erreur — ce qui montre
    // la limite du crochet : une zone intermédiaire le court-circuite. L'app
    // n'en installe aucune, ses erreurs asynchrones vont donc bien au journal.
    expect(zoneErrors.single, isA<StateError>());
  });

  test('rétablit les gestionnaires précédents', () {
    final ours = FlutterError.onError;
    final chained = installErrorHandlers(LoggerApplicationService(InMemoryLoggerService()));
    expect(FlutterError.onError, isNot(same(ours)));
    chained();
    expect(FlutterError.onError, same(ours));
  });
}
