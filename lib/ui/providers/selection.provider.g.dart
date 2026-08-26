// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selection.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sélection multiple de la liste de contacts.
///
/// Un appui long ouvre le mode sélection ; la barre de titre bascule alors sur
/// « N sélectionnés » et ses actions. Vider la sélection referme le mode — il
/// n'y a donc pas de drapeau séparé à tenir synchronisé.

@ProviderFor(ContactSelection)
final contactSelectionProvider = ContactSelectionProvider._();

/// Sélection multiple de la liste de contacts.
///
/// Un appui long ouvre le mode sélection ; la barre de titre bascule alors sur
/// « N sélectionnés » et ses actions. Vider la sélection referme le mode — il
/// n'y a donc pas de drapeau séparé à tenir synchronisé.
final class ContactSelectionProvider extends $NotifierProvider<ContactSelection, Set<String>> {
  /// Sélection multiple de la liste de contacts.
  ///
  /// Un appui long ouvre le mode sélection ; la barre de titre bascule alors sur
  /// « N sélectionnés » et ses actions. Vider la sélection referme le mode — il
  /// n'y a donc pas de drapeau séparé à tenir synchronisé.
  ContactSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactSelectionHash();

  @$internal
  @override
  ContactSelection create() => ContactSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$contactSelectionHash() => r'91d6fcf58a358169d74681386713ff2315adca4b';

/// Sélection multiple de la liste de contacts.
///
/// Un appui long ouvre le mode sélection ; la barre de titre bascule alors sur
/// « N sélectionnés » et ses actions. Vider la sélection referme le mode — il
/// n'y a donc pas de drapeau séparé à tenir synchronisé.

abstract class _$ContactSelection extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
