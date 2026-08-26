// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Router unique. Les deux onglets du bas (« Contacts » et « Organiser ») sont
/// portés par un `StatefulShellRoute` : chacun garde sa pile et sa position de
/// défilement quand on passe de l'un à l'autre, comme dans Google Contacts.

@ProviderFor(goRouter)
final goRouterProvider = GoRouterProvider._();

/// Router unique. Les deux onglets du bas (« Contacts » et « Organiser ») sont
/// portés par un `StatefulShellRoute` : chacun garde sa pile et sa position de
/// défilement quand on passe de l'un à l'autre, comme dans Google Contacts.

final class GoRouterProvider extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Router unique. Les deux onglets du bas (« Contacts » et « Organiser ») sont
  /// portés par un `StatefulShellRoute` : chacun garde sa pile et sa position de
  /// défilement quand on passe de l'un à l'autre, comme dans Google Contacts.
  GoRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return goRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<GoRouter>(value));
  }
}

String _$goRouterHash() => r'f7d03c7d18c745b91a2c338048478a3ee72c5cc1';
