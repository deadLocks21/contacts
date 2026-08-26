// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'infra_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Store local — implémentation mémoire par défaut, **surchargée** dans
/// `main()` par l'implémentation sqflite sur mobile et desktop.

@ProviderFor(localRecordStore)
final localRecordStoreProvider = LocalRecordStoreProvider._();

/// Store local — implémentation mémoire par défaut, **surchargée** dans
/// `main()` par l'implémentation sqflite sur mobile et desktop.

final class LocalRecordStoreProvider
    extends $FunctionalProvider<LocalRecordStore, LocalRecordStore, LocalRecordStore>
    with $Provider<LocalRecordStore> {
  /// Store local — implémentation mémoire par défaut, **surchargée** dans
  /// `main()` par l'implémentation sqflite sur mobile et desktop.
  LocalRecordStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localRecordStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localRecordStoreHash();

  @$internal
  @override
  $ProviderElement<LocalRecordStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocalRecordStore create(Ref ref) {
    return localRecordStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalRecordStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalRecordStore>(value),
    );
  }
}

String _$localRecordStoreHash() => r'd832c6a563a2bce73733f058b5bb873f63d5af83';

/// Émet à chaque écriture du store : les providers de données s'y abonnent
/// pour se recalculer. Le flux porte une révision monotone, sans quoi Riverpod
/// ne renotifierait qu'au premier changement.

@ProviderFor(storeChanges)
final storeChangesProvider = StoreChangesProvider._();

/// Émet à chaque écriture du store : les providers de données s'y abonnent
/// pour se recalculer. Le flux porte une révision monotone, sans quoi Riverpod
/// ne renotifierait qu'au premier changement.

final class StoreChangesProvider extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Émet à chaque écriture du store : les providers de données s'y abonnent
  /// pour se recalculer. Le flux porte une révision monotone, sans quoi Riverpod
  /// ne renotifierait qu'au premier changement.
  StoreChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeChangesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeChangesHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return storeChanges(ref);
  }
}

String _$storeChangesHash() => r'b513add5175e724332e5117c11dcbf2c1569f7da';

/// Sur le web il n'y a pas de système de fichiers à alimenter : le chemin
/// choisi (une URL blob) est conservé tel quel.

@ProviderFor(photoStore)
final photoStoreProvider = PhotoStoreProvider._();

/// Sur le web il n'y a pas de système de fichiers à alimenter : le chemin
/// choisi (une URL blob) est conservé tel quel.

final class PhotoStoreProvider extends $FunctionalProvider<PhotoStore, PhotoStore, PhotoStore>
    with $Provider<PhotoStore> {
  /// Sur le web il n'y a pas de système de fichiers à alimenter : le chemin
  /// choisi (une URL blob) est conservé tel quel.
  PhotoStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'photoStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$photoStoreHash();

  @$internal
  @override
  $ProviderElement<PhotoStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PhotoStore create(Ref ref) {
    return photoStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhotoStore value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<PhotoStore>(value));
  }
}

String _$photoStoreHash() => r'1e409647a7bbbee519e84ee049d6faf2d8651e81';

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends $FunctionalProvider<SettingsRepository, SettingsRepository, SettingsRepository>
    with $Provider<SettingsRepository> {
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() => r'0c75fa85006f6ddd4b7da68fc7b9c0d1593b8452';
