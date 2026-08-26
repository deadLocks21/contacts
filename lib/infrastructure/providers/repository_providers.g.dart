// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Assemblage des ports : carnet du système sur mobile, doublures locales
/// partout ailleurs. C'est le seul endroit qui connaît les deux.

@ProviderFor(contactRepository)
final contactRepositoryProvider = ContactRepositoryProvider._();

/// Assemblage des ports : carnet du système sur mobile, doublures locales
/// partout ailleurs. C'est le seul endroit qui connaît les deux.

final class ContactRepositoryProvider
    extends $FunctionalProvider<ContactRepository, ContactRepository, ContactRepository>
    with $Provider<ContactRepository> {
  /// Assemblage des ports : carnet du système sur mobile, doublures locales
  /// partout ailleurs. C'est le seul endroit qui connaît les deux.
  ContactRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactRepositoryHash();

  @$internal
  @override
  $ProviderElement<ContactRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ContactRepository create(Ref ref) {
    return contactRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactRepository>(value),
    );
  }
}

String _$contactRepositoryHash() => r'031b32ad3ba1910104531ab34da9bdddf5ca235c';

@ProviderFor(labelRepository)
final labelRepositoryProvider = LabelRepositoryProvider._();

final class LabelRepositoryProvider
    extends $FunctionalProvider<LabelRepository, LabelRepository, LabelRepository>
    with $Provider<LabelRepository> {
  LabelRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'labelRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$labelRepositoryHash();

  @$internal
  @override
  $ProviderElement<LabelRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LabelRepository create(Ref ref) {
    return labelRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LabelRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LabelRepository>(value),
    );
  }
}

String _$labelRepositoryHash() => r'4b1918241ba4f6de86880c4c49c8d064d57b3527';

/// La corbeille est toujours locale : le carnet du système n'en a pas.

@ProviderFor(trashRepository)
final trashRepositoryProvider = TrashRepositoryProvider._();

/// La corbeille est toujours locale : le carnet du système n'en a pas.

final class TrashRepositoryProvider
    extends $FunctionalProvider<TrashRepository, TrashRepository, TrashRepository>
    with $Provider<TrashRepository> {
  /// La corbeille est toujours locale : le carnet du système n'en a pas.
  TrashRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trashRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trashRepositoryHash();

  @$internal
  @override
  $ProviderElement<TrashRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TrashRepository create(Ref ref) {
    return trashRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrashRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrashRepository>(value),
    );
  }
}

String _$trashRepositoryHash() => r'd7c58915cdacad332a062c8ef691b508b908eab1';

/// Émet à chaque écriture, d'où qu'elle vienne — carnet du système (y compris
/// modifié par une autre app) comme corbeille. Les vues du carnet s'y abonnent
/// pour se recalculer.

@ProviderFor(storeChanges)
final storeChangesProvider = StoreChangesProvider._();

/// Émet à chaque écriture, d'où qu'elle vienne — carnet du système (y compris
/// modifié par une autre app) comme corbeille. Les vues du carnet s'y abonnent
/// pour se recalculer.

final class StoreChangesProvider extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Émet à chaque écriture, d'où qu'elle vienne — carnet du système (y compris
  /// modifié par une autre app) comme corbeille. Les vues du carnet s'y abonnent
  /// pour se recalculer.
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

String _$storeChangesHash() => r'0e462171badd7dfeda327acd34433e678e6501d2';
