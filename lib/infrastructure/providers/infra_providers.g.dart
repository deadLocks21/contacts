// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'infra_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Le carnet d'adresses du système n'existe que sur mobile. Ailleurs (desktop,
/// tests), l'app tourne sur un carnet simulé, alimenté par [DemoSeed] : l'UI
/// reste travaillable et testable sans téléphone.

@ProviderFor(useDeviceContacts)
final useDeviceContactsProvider = UseDeviceContactsProvider._();

/// Le carnet d'adresses du système n'existe que sur mobile. Ailleurs (desktop,
/// tests), l'app tourne sur un carnet simulé, alimenté par [DemoSeed] : l'UI
/// reste travaillable et testable sans téléphone.

final class UseDeviceContactsProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Le carnet d'adresses du système n'existe que sur mobile. Ailleurs (desktop,
  /// tests), l'app tourne sur un carnet simulé, alimenté par [DemoSeed] : l'UI
  /// reste travaillable et testable sans téléphone.
  UseDeviceContactsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'useDeviceContactsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$useDeviceContactsHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return useDeviceContacts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<bool>(value));
  }
}

String _$useDeviceContactsHash() => r'4ce800a8558cf95b19416c98025dc3a816fe7f83';

/// Store local — implémentation mémoire par défaut, **surchargée** dans
/// `main()` par l'implémentation sqflite. Il porte la corbeille, et le carnet
/// simulé là où il n'y a pas de carnet système.

@ProviderFor(localRecordStore)
final localRecordStoreProvider = LocalRecordStoreProvider._();

/// Store local — implémentation mémoire par défaut, **surchargée** dans
/// `main()` par l'implémentation sqflite. Il porte la corbeille, et le carnet
/// simulé là où il n'y a pas de carnet système.

final class LocalRecordStoreProvider
    extends $FunctionalProvider<LocalRecordStore, LocalRecordStore, LocalRecordStore>
    with $Provider<LocalRecordStore> {
  /// Store local — implémentation mémoire par défaut, **surchargée** dans
  /// `main()` par l'implémentation sqflite. Il porte la corbeille, et le carnet
  /// simulé là où il n'y a pas de carnet système.
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
