import 'package:contacts/core/domain/services/photo.store.dart';
import 'package:contacts/core/domain/services/settings.repository.dart';
import 'package:contacts/infrastructure/persistence/local_record_store.dart';
import 'package:contacts/infrastructure/photos/local_file.photo.store.dart';
import 'package:contacts/infrastructure/settings/shared_prefs.settings.repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'infra_providers.g.dart';

/// Store local — implémentation mémoire par défaut, **surchargée** dans
/// `main()` par l'implémentation sqflite sur mobile et desktop.
@Riverpod(keepAlive: true)
LocalRecordStore localRecordStore(Ref ref) => InMemoryLocalRecordStore();

/// Émet à chaque écriture du store : les providers de données s'y abonnent
/// pour se recalculer. Le flux porte une révision monotone, sans quoi Riverpod
/// ne renotifierait qu'au premier changement.
@riverpod
Stream<int> storeChanges(Ref ref) => ref.watch(localRecordStoreProvider).changes;

@Riverpod(keepAlive: true)
PhotoStore photoStore(Ref ref) => LocalFilePhotoStore();

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) => SharedPreferencesSettingsRepository();
