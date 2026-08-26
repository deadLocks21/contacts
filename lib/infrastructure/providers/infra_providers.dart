import 'package:contacts/core/domain/services/settings.repository.dart';
import 'package:contacts/infrastructure/persistence/local_record_store.dart';
import 'package:contacts/infrastructure/settings/shared_prefs.settings.repository.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'infra_providers.g.dart';

/// Le carnet d'adresses du système n'existe que sur mobile. Ailleurs (desktop,
/// tests), l'app tourne sur un carnet simulé, alimenté par [DemoSeed] : l'UI
/// reste travaillable et testable sans téléphone.
@Riverpod(keepAlive: true)
bool useDeviceContacts(Ref ref) =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// Store local — implémentation mémoire par défaut, **surchargée** dans
/// `main()` par l'implémentation sqflite. Il porte la corbeille, et le carnet
/// simulé là où il n'y a pas de carnet système.
@Riverpod(keepAlive: true)
LocalRecordStore localRecordStore(Ref ref) => InMemoryLocalRecordStore();

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) => SharedPreferencesSettingsRepository();
