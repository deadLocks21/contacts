// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Assemblage des cas d'usage du carnet. L'UI ne consomme que ces services :
/// elle ne voit jamais un repository, encore moins son implémentation.

@ProviderFor(contactsService)
final contactsServiceProvider = ContactsServiceProvider._();

/// Assemblage des cas d'usage du carnet. L'UI ne consomme que ces services :
/// elle ne voit jamais un repository, encore moins son implémentation.

final class ContactsServiceProvider
    extends
        $FunctionalProvider<
          ContactsApplicationService,
          ContactsApplicationService,
          ContactsApplicationService
        >
    with $Provider<ContactsApplicationService> {
  /// Assemblage des cas d'usage du carnet. L'UI ne consomme que ces services :
  /// elle ne voit jamais un repository, encore moins son implémentation.
  ContactsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactsServiceHash();

  @$internal
  @override
  $ProviderElement<ContactsApplicationService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ContactsApplicationService create(Ref ref) {
    return contactsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactsApplicationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactsApplicationService>(value),
    );
  }
}

String _$contactsServiceHash() => r'c43aad22e706008f4af8a57959c6211470ce14ae';

@ProviderFor(labelsService)
final labelsServiceProvider = LabelsServiceProvider._();

final class LabelsServiceProvider
    extends
        $FunctionalProvider<
          LabelsApplicationService,
          LabelsApplicationService,
          LabelsApplicationService
        >
    with $Provider<LabelsApplicationService> {
  LabelsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'labelsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$labelsServiceHash();

  @$internal
  @override
  $ProviderElement<LabelsApplicationService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LabelsApplicationService create(Ref ref) {
    return labelsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LabelsApplicationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LabelsApplicationService>(value),
    );
  }
}

String _$labelsServiceHash() => r'e38780c43f05b23493a3b2ad1c34ecb05e140927';

@ProviderFor(organizeService)
final organizeServiceProvider = OrganizeServiceProvider._();

final class OrganizeServiceProvider
    extends
        $FunctionalProvider<
          OrganizeApplicationService,
          OrganizeApplicationService,
          OrganizeApplicationService
        >
    with $Provider<OrganizeApplicationService> {
  OrganizeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'organizeServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$organizeServiceHash();

  @$internal
  @override
  $ProviderElement<OrganizeApplicationService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrganizeApplicationService create(Ref ref) {
    return organizeService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrganizeApplicationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrganizeApplicationService>(value),
    );
  }
}

String _$organizeServiceHash() => r'a16ea06fda09ba63a2952644c4ea8c3ebf3e3487';

@ProviderFor(settingsService)
final settingsServiceProvider = SettingsServiceProvider._();

final class SettingsServiceProvider
    extends
        $FunctionalProvider<
          SettingsApplicationService,
          SettingsApplicationService,
          SettingsApplicationService
        >
    with $Provider<SettingsApplicationService> {
  SettingsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsServiceHash();

  @$internal
  @override
  $ProviderElement<SettingsApplicationService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsApplicationService create(Ref ref) {
    return settingsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsApplicationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsApplicationService>(value),
    );
  }
}

String _$settingsServiceHash() => r'4f8ec0fbbb1f138d0f014055865925cf10888451';
