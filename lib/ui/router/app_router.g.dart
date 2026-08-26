// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Router unique. Les trois onglets du bas (« Contacts », « Faits marquants »
/// et « Organiser ») sont portés par un `StatefulShellRoute` : chacun garde sa
/// pile et sa position de défilement quand on passe de l'un à l'autre, comme
/// dans Google Contacts.

@ProviderFor(goRouter)
final goRouterProvider = GoRouterProvider._();

/// Router unique. Les trois onglets du bas (« Contacts », « Faits marquants »
/// et « Organiser ») sont portés par un `StatefulShellRoute` : chacun garde sa
/// pile et sa position de défilement quand on passe de l'un à l'autre, comme
/// dans Google Contacts.

final class GoRouterProvider extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Router unique. Les trois onglets du bas (« Contacts », « Faits marquants »
  /// et « Organiser ») sont portés par un `StatefulShellRoute` : chacun garde sa
  /// pile et sa position de défilement quand on passe de l'un à l'autre, comme
  /// dans Google Contacts.
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

String _$goRouterHash() => r'ac8267ac3a2e1b3287651d3f69c31755e3489370';
