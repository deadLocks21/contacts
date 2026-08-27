// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootstrap_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Démarrage de l'app, avant tout affichage : réglages relus, corbeille purgée
/// de ce qui a dépassé 30 jours, carnet de démonstration écrit si le store est
/// vierge.
///
/// La purge se fait ici parce que c'est le seul moment où l'app peut constater
/// l'expiration : sans tâche de fond, une fiche supprimée il y a 31 jours ne
/// disparaît qu'au prochain lancement.
///
/// Chaque étape laisse une trace. Un démarrage est l'endroit où une panne se
/// voit le moins — l'app affiche une roue qui tourne, puis une liste vide — et
/// celui où elle coûte le plus cher. L'échec du provider lui-même est journalisé
/// par [LoggingProviderObserver], inutile de le rattraper ici.

@ProviderFor(bootstrap)
final bootstrapProvider = BootstrapProvider._();

/// Démarrage de l'app, avant tout affichage : réglages relus, corbeille purgée
/// de ce qui a dépassé 30 jours, carnet de démonstration écrit si le store est
/// vierge.
///
/// La purge se fait ici parce que c'est le seul moment où l'app peut constater
/// l'expiration : sans tâche de fond, une fiche supprimée il y a 31 jours ne
/// disparaît qu'au prochain lancement.
///
/// Chaque étape laisse une trace. Un démarrage est l'endroit où une panne se
/// voit le moins — l'app affiche une roue qui tourne, puis une liste vide — et
/// celui où elle coûte le plus cher. L'échec du provider lui-même est journalisé
/// par [LoggingProviderObserver], inutile de le rattraper ici.

final class BootstrapProvider extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Démarrage de l'app, avant tout affichage : réglages relus, corbeille purgée
  /// de ce qui a dépassé 30 jours, carnet de démonstration écrit si le store est
  /// vierge.
  ///
  /// La purge se fait ici parce que c'est le seul moment où l'app peut constater
  /// l'expiration : sans tâche de fond, une fiche supprimée il y a 31 jours ne
  /// disparaît qu'au prochain lancement.
  ///
  /// Chaque étape laisse une trace. Un démarrage est l'endroit où une panne se
  /// voit le moins — l'app affiche une roue qui tourne, puis une liste vide — et
  /// celui où elle coûte le plus cher. L'échec du provider lui-même est journalisé
  /// par [LoggingProviderObserver], inutile de le rattraper ici.
  BootstrapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bootstrapProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bootstrapHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return bootstrap(ref);
  }
}

String _$bootstrapHash() => r'c79d8f5412a454baea8452c07c07c28de15f4196';
