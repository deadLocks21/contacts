import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:contacts/core/domain/model/log_level.dart';
import 'package:contacts/infrastructure/logger/in_memory.logger.service.dart';
import 'package:contacts/infrastructure/observability/logging.provider_observer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'observateur est le filet des chemins de lecture : tout ce qui échoue
/// derrière un `AsyncValue` — la liste, une fiche, la recherche, l'amorçage —
/// passe par lui, et par lui seul.
void main() {
  late InMemoryLoggerService sink;

  ProviderContainer observedContainer() {
    sink = InMemoryLoggerService();
    final logger = LoggerApplicationService(sink);
    final container = ProviderContainer(observers: [LoggingProviderObserver(() => logger)]);
    addTearDown(container.dispose);
    return container;
  }

  test('journalise un provider synchrone qui lève, avec son nom', () {
    final broken = Provider<int>((ref) => throw StateError('base fermée'), name: 'contactList');
    final container = observedContainer();

    // L'exception continue sa route jusqu'à l'UI : on ne fait que l'écouter.
    expect(() => container.read(broken), throwsA(anything));

    final record = sink.records.single;
    expect(record.message, 'provider.failed');
    expect(record.level, LogLevel.error);
    expect(record.attributes['provider'], 'contactList');
    expect(record.error, isA<StateError>());
    expect(record.stack, isNotNull);
  });

  test('journalise aussi un futur qui échoue après un await', () async {
    // Le cas qui compte : presque toutes les lectures du carnet sont
    // asynchrones, et Riverpod ne les annonce pas via `providerDidFail`.
    final broken = FutureProvider<int>(
      (ref) async => throw const FormatException('carnet illisible'),
      name: 'contactDetail',
    );
    final container = observedContainer();

    final subscription = container.listen(broken, (_, _) {});
    await Future<void>.delayed(Duration.zero);
    subscription.close();

    expect(sink.messages, ['provider.failed']);
    expect(sink.records.single.attributes['provider'], 'contactDetail');
    expect(sink.records.single.error, isA<FormatException>());
  });

  test('n\'écrit qu\'une fois le même échec, et de nouveau s\'il revient', () async {
    var attempt = 0;
    final flaky = FutureProvider<int>(
      (ref) async => throw StateError('tentative ${++attempt}'),
      name: 'contactList',
    );
    final container = observedContainer();

    final first = container.listen(flaky, (_, _) {});
    await Future<void>.delayed(Duration.zero);
    first.close();
    expect(sink.messages, ['provider.failed']);

    container.invalidate(flaky);
    final second = container.listen(flaky, (_, _) {});
    await Future<void>.delayed(Duration.zero);
    second.close();

    // Deux exceptions distinctes : deux lignes. Le dédoublonnage ne masque que
    // la double annonce d'un seul et même échec.
    expect(sink.messages, ['provider.failed', 'provider.failed']);
  });

  test('un futur qui aboutit après un échec n\'écrit rien de plus', () async {
    final container = observedContainer();
    final values = FutureProvider<int>((ref) async => 1, name: 'settings');

    final subscription = container.listen(values, (_, _) {});
    await Future<void>.delayed(Duration.zero);
    subscription.close();

    expect(sink.records, isEmpty);
  });

  test('un provider qui aboutit n\'écrit rien', () {
    final fine = Provider<int>((ref) => 1, name: 'settings');
    final container = observedContainer();

    expect(container.read(fine), 1);

    expect(sink.records, isEmpty);
  });

  test('un journal lui-même en panne ne fait pas tomber l\'app', () {
    final broken = Provider<int>((ref) => throw StateError('base fermée'), name: 'contactList');
    final container = ProviderContainer(
      observers: [LoggingProviderObserver(() => throw StateError('journal indisponible'))],
    );
    addTearDown(container.dispose);

    // L'erreur d'origine remonte intacte ; celle du journal est avalée.
    expect(() => container.read(broken), throwsA(anything));
  });
}
