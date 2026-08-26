// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_view.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ContactView)
final contactViewProvider = ContactViewProvider._();

final class ContactViewProvider extends $NotifierProvider<ContactView, ContactViewState> {
  ContactViewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactViewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactViewHash();

  @$internal
  @override
  ContactView create() => ContactView();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactViewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactViewState>(value),
    );
  }
}

String _$contactViewHash() => r'2cdf11a713a89003a3ff56c0a350ec8ee30f1e7d';

abstract class _$ContactView extends $Notifier<ContactViewState> {
  ContactViewState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ContactViewState, ContactViewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ContactViewState, ContactViewState>,
              ContactViewState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
