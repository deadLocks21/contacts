import 'package:contacts/core/domain/model/contact.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/infrastructure/logger/in_memory.logger.service.dart';
import 'package:contacts/infrastructure/observability/logging.provider_observer.dart';
import 'package:contacts/infrastructure/providers/infra_providers.dart';
import 'package:contacts/infrastructure/providers/logger.service_provider.dart';
import 'package:contacts/infrastructure/providers/repository_providers.dart';
import 'package:contacts/infrastructure/settings/shared_prefs.settings.repository.dart';
import 'package:contacts/ui/providers/contact_data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Le carnet en panne, tel que l'app le rencontre : un canal natif qui refuse,
/// une base illisible. L'écran affiche son erreur — le journal doit en garder
/// une trace exploitable, avec le nom du provider fautif.
class _BrokenContactRepository implements ContactRepository {
  @override
  Stream<int> get changes => const Stream.empty();

  @override
  Future<List<Contact>> listAll() async => throw StateError('carnet injoignable');

  @override
  Future<Contact?> getById(String id) async => throw StateError('carnet injoignable');

  @override
  Future<String> save(Contact contact) async => throw StateError('carnet injoignable');

  @override
  Future<void> saveAll(Iterable<Contact> contacts) async => throw StateError('carnet injoignable');

  @override
  Future<void> delete(Iterable<String> ids) async => throw StateError('carnet injoignable');
}

void main() {
  test('une lecture du carnet qui échoue laisse une ligne nommée', () async {
    final sink = InMemoryLoggerService();
    late final ProviderContainer container;
    container = ProviderContainer(
      observers: [LoggingProviderObserver(() => container.read(loggerProvider))],
      overrides: [
        useDeviceContactsProvider.overrideWithValue(false),
        loggerServiceProvider.overrideWithValue(sink),
        settingsRepositoryProvider.overrideWithValue(InMemorySettingsRepository()),
        contactRepositoryProvider.overrideWithValue(_BrokenContactRepository()),
      ],
    );
    addTearDown(container.dispose);

    final subscription = container.listen(contactListProvider(), (_, _) {});
    await Future<void>.delayed(Duration.zero);
    subscription.close();

    final record = sink.records.firstWhere((r) => r.message == 'provider.failed');
    expect(record.attributes['provider'], 'contactListProvider');
    expect(record.error, isA<StateError>());
  });
}
