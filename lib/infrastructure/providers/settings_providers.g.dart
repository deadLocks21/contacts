// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Réglages d'affichage, relus au démarrage puis tenus en mémoire.
///
/// Chaque modification est écrite **puis** publiée : l'écran de réglages
/// n'affiche pas une valeur qui ne serait pas encore sur le disque.

@ProviderFor(SettingsController)
final settingsControllerProvider = SettingsControllerProvider._();

/// Réglages d'affichage, relus au démarrage puis tenus en mémoire.
///
/// Chaque modification est écrite **puis** publiée : l'écran de réglages
/// n'affiche pas une valeur qui ne serait pas encore sur le disque.
final class SettingsControllerProvider
    extends $AsyncNotifierProvider<SettingsController, AppSettings> {
  /// Réglages d'affichage, relus au démarrage puis tenus en mémoire.
  ///
  /// Chaque modification est écrite **puis** publiée : l'écran de réglages
  /// n'affiche pas une valeur qui ne serait pas encore sur le disque.
  SettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsControllerHash();

  @$internal
  @override
  SettingsController create() => SettingsController();
}

String _$settingsControllerHash() => r'0889a9fdbf518b2f16f92ac7609a70d23cf7527f';

/// Réglages d'affichage, relus au démarrage puis tenus en mémoire.
///
/// Chaque modification est écrite **puis** publiée : l'écran de réglages
/// n'affiche pas une valeur qui ne serait pas encore sur le disque.

abstract class _$SettingsController extends $AsyncNotifier<AppSettings> {
  FutureOr<AppSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppSettings>, AppSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppSettings>, AppSettings>,
              AsyncValue<AppSettings>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Réglages courants, avec repli sur les valeurs par défaut tant que la
/// lecture n'a pas abouti — l'UI n'a ainsi jamais à gérer un état « pas encore
/// chargé » pour un simple critère de tri.

@ProviderFor(currentSettings)
final currentSettingsProvider = CurrentSettingsProvider._();

/// Réglages courants, avec repli sur les valeurs par défaut tant que la
/// lecture n'a pas abouti — l'UI n'a ainsi jamais à gérer un état « pas encore
/// chargé » pour un simple critère de tri.

final class CurrentSettingsProvider
    extends $FunctionalProvider<AppSettings, AppSettings, AppSettings>
    with $Provider<AppSettings> {
  /// Réglages courants, avec repli sur les valeurs par défaut tant que la
  /// lecture n'a pas abouti — l'UI n'a ainsi jamais à gérer un état « pas encore
  /// chargé » pour un simple critère de tri.
  CurrentSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentSettingsHash();

  @$internal
  @override
  $ProviderElement<AppSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppSettings create(Ref ref) {
    return currentSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppSettings>(value),
    );
  }
}

String _$currentSettingsHash() => r'b4148209b5890ef6f01f00c30ca46a9f50a28aa2';
