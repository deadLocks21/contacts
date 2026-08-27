import 'package:contacts/core/domain/model/log_level.dart';
import 'package:contacts/infrastructure/logger/console.logger.service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// `developer.log` ne parle qu'au service VM : ce que `flutter run` affiche
/// vient de `debugPrint`, et de lui seul. C'est donc lui qu'on observe.
void main() {
  late List<String> printed;
  late DebugPrintCallback previous;

  setUp(() {
    printed = [];
    previous = debugPrint;
    debugPrint = (message, {wrapWidth}) => printed.add(message ?? '');
  });

  tearDown(() => debugPrint = previous);

  test('sans seuil, rien n\'atteint le terminal', () async {
    await const ConsoleLoggerService().log(LogLevel.error, 'dart.uncaught');
    expect(printed, isEmpty);
  });

  test('au seuil warn, une erreur et son avertissement se voient', () async {
    const logger = ConsoleLoggerService(mirrorFrom: LogLevel.warn);

    await logger.log(LogLevel.warn, 'contacts.permission.denied');
    await logger.log(
      LogLevel.error,
      'dart.uncaught',
      error: const FormatException('carnet illisible'),
      stack: StackTrace.fromString('#0 quelque part'),
    );

    expect(printed.first, contains('WARN contacts.permission.denied'));
    expect(printed, anyElement(contains('ERROR dart.uncaught')));
    expect(printed, anyElement(contains('carnet illisible')));
    expect(printed, anyElement(contains('quelque part')));
  });

  test('au seuil warn, le bavardage courant reste dans DevTools', () async {
    const logger = ConsoleLoggerService(mirrorFrom: LogLevel.warn);

    await logger.log(LogLevel.info, 'contact.saved');
    await logger.log(LogLevel.debug, 'app.route');

    expect(printed, isEmpty);
  });

  test('les attributs suivent la ligne, lisibles au grep', () async {
    const logger = ConsoleLoggerService(mirrorFrom: LogLevel.warn);

    await logger.log(
      LogLevel.warn,
      'action.unsupported',
      attributes: {'action': 'dial', 'uri.scheme': 'tel', 'contexte': 'deux mots'},
    );

    expect(printed.single, contains('action=dial uri.scheme=tel'));
    // Guillemets seulement là où une espace casserait la lecture.
    expect(printed.single, contains('contexte="deux mots"'));
  });
}
