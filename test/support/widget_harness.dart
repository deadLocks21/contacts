import 'package:contacts/core/application/persistence/entity_codecs.dart';
import 'package:contacts/core/domain/model/contact.dart';
import 'package:contacts/core/domain/model/contact_label.dart';
import 'package:contacts/core/domain/services/settings.repository.dart';
import 'package:contacts/infrastructure/persistence/local_record_store.dart';
import 'package:contacts/infrastructure/providers/infra_providers.dart';
import 'package:contacts/infrastructure/settings/shared_prefs.settings.repository.dart';
import 'package:contacts/ui/router/app_router.dart';
import 'package:contacts/ui/theme/app_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Monte l'app complète (router compris) sur un store en mémoire pré-rempli.
///
/// Les doublures sont les implémentations `InMemory*` de l'app : les tests de
/// widgets traversent donc le vrai chemin de données, des providers Riverpod
/// jusqu'aux codecs de persistance.
Future<ProviderContainer> pumpContactsApp(
  WidgetTester tester, {
  List<Contact> contacts = const [],
  List<Contact> trashed = const [],
  List<ContactLabel> labels = const [],
  SettingsRepository? settings,
}) async {
  final store = InMemoryLocalRecordStore();
  await store.upsert(contactCodec.resource, [
    for (final c in contacts)
      (
        id: contactCodec.idOf(c),
        payload: contactCodec.toJson(c),
        updatedAt: contactCodec.updatedAtOf(c),
        deletedAt: contactCodec.deletedAtOf(c),
      ),
  ]);
  // La corbeille est une ressource à part : le carnet ne la porte plus.
  await store.upsert('trash', [
    for (final c in trashed)
      (
        id: contactCodec.idOf(c),
        payload: contactCodec.toJson(c),
        updatedAt: contactCodec.updatedAtOf(c),
        deletedAt: contactCodec.deletedAtOf(c),
      ),
  ]);
  await store.upsert(labelCodec.resource, [
    for (final l in labels)
      (
        id: labelCodec.idOf(l),
        payload: labelCodec.toJson(l),
        updatedAt: labelCodec.updatedAtOf(l),
        deletedAt: null,
      ),
  ]);

  final container = ProviderContainer(
    overrides: [
      // `defaultTargetPlatform` vaut Android dans les tests de widgets : sans
      // cette bascule, l'app irait interroger le carnet du système, dont le
      // canal natif n'existe pas ici.
      useDeviceContactsProvider.overrideWithValue(false),
      localRecordStoreProvider.overrideWithValue(store),
      settingsRepositoryProvider.overrideWithValue(settings ?? InMemorySettingsRepository()),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: AppThemeData.buildLightTheme(),
        locale: const Locale('fr', 'FR'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('fr', 'FR')],
        routerConfig: container.read(goRouterProvider),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}
