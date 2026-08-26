// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Toutes les vues du carnet observent [storeChangesProvider] : une écriture,
/// d'où qu'elle vienne, rafraîchit la liste, la fiche ouverte et les compteurs
/// sans que l'écran qui a écrit ait à prévenir les autres.
/// La liste d'accueil, éventuellement restreinte à une étiquette ou aux favoris.

@ProviderFor(contactList)
final contactListProvider = ContactListFamily._();

/// Toutes les vues du carnet observent [storeChangesProvider] : une écriture,
/// d'où qu'elle vienne, rafraîchit la liste, la fiche ouverte et les compteurs
/// sans que l'écran qui a écrit ait à prévenir les autres.
/// La liste d'accueil, éventuellement restreinte à une étiquette ou aux favoris.

final class ContactListProvider
    extends
        $FunctionalProvider<
          AsyncValue<ContactListDto>,
          ContactListDto,
          FutureOr<ContactListDto>
        >
    with $FutureModifier<ContactListDto>, $FutureProvider<ContactListDto> {
  /// Toutes les vues du carnet observent [storeChangesProvider] : une écriture,
  /// d'où qu'elle vienne, rafraîchit la liste, la fiche ouverte et les compteurs
  /// sans que l'écran qui a écrit ait à prévenir les autres.
  /// La liste d'accueil, éventuellement restreinte à une étiquette ou aux favoris.
  ContactListProvider._({
    required ContactListFamily super.from,
    required ({String? labelId, bool starredOnly}) super.argument,
  }) : super(
         retry: null,
         name: r'contactListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$contactListHash();

  @override
  String toString() {
    return r'contactListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ContactListDto> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ContactListDto> create(Ref ref) {
    final argument = this.argument as ({String? labelId, bool starredOnly});
    return contactList(
      ref,
      labelId: argument.labelId,
      starredOnly: argument.starredOnly,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ContactListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$contactListHash() => r'd621f31e721e858f16b8fd46175a2aca7c582daa';

/// Toutes les vues du carnet observent [storeChangesProvider] : une écriture,
/// d'où qu'elle vienne, rafraîchit la liste, la fiche ouverte et les compteurs
/// sans que l'écran qui a écrit ait à prévenir les autres.
/// La liste d'accueil, éventuellement restreinte à une étiquette ou aux favoris.

final class ContactListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ContactListDto>,
          ({String? labelId, bool starredOnly})
        > {
  ContactListFamily._()
    : super(
        retry: null,
        name: r'contactListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Toutes les vues du carnet observent [storeChangesProvider] : une écriture,
  /// d'où qu'elle vienne, rafraîchit la liste, la fiche ouverte et les compteurs
  /// sans que l'écran qui a écrit ait à prévenir les autres.
  /// La liste d'accueil, éventuellement restreinte à une étiquette ou aux favoris.

  ContactListProvider call({String? labelId, bool starredOnly = false}) =>
      ContactListProvider._(
        argument: (labelId: labelId, starredOnly: starredOnly),
        from: this,
      );

  @override
  String toString() => r'contactListProvider';
}

/// La fiche détaillée d'un contact. `null` = la fiche n'existe plus.

@ProviderFor(contactDetail)
final contactDetailProvider = ContactDetailFamily._();

/// La fiche détaillée d'un contact. `null` = la fiche n'existe plus.

final class ContactDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<ContactDetailDto?>,
          ContactDetailDto?,
          FutureOr<ContactDetailDto?>
        >
    with
        $FutureModifier<ContactDetailDto?>,
        $FutureProvider<ContactDetailDto?> {
  /// La fiche détaillée d'un contact. `null` = la fiche n'existe plus.
  ContactDetailProvider._({
    required ContactDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'contactDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$contactDetailHash();

  @override
  String toString() {
    return r'contactDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ContactDetailDto?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ContactDetailDto?> create(Ref ref) {
    final argument = this.argument as String;
    return contactDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$contactDetailHash() => r'3e9fde38d050c76898878af72d1e93d6b6e4f86b';

/// La fiche détaillée d'un contact. `null` = la fiche n'existe plus.

final class ContactDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ContactDetailDto?>, String> {
  ContactDetailFamily._()
    : super(
        retry: null,
        name: r'contactDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// La fiche détaillée d'un contact. `null` = la fiche n'existe plus.

  ContactDetailProvider call(String contactId) =>
      ContactDetailProvider._(argument: contactId, from: this);

  @override
  String toString() => r'contactDetailProvider';
}

/// Les étiquettes et leur nombre de contacts (tiroir de navigation).

@ProviderFor(labelList)
final labelListProvider = LabelListProvider._();

/// Les étiquettes et leur nombre de contacts (tiroir de navigation).

final class LabelListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LabelDto>>,
          List<LabelDto>,
          FutureOr<List<LabelDto>>
        >
    with $FutureModifier<List<LabelDto>>, $FutureProvider<List<LabelDto>> {
  /// Les étiquettes et leur nombre de contacts (tiroir de navigation).
  LabelListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'labelListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$labelListHash();

  @$internal
  @override
  $FutureProviderElement<List<LabelDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LabelDto>> create(Ref ref) {
    return labelList(ref);
  }
}

String _$labelListHash() => r'7501a601154dc7ba8743e6ac0b74546de9af79d9';

/// Résultats de recherche pour [query]. Requête vide = liste vide.

@ProviderFor(searchResults)
final searchResultsProvider = SearchResultsFamily._();

/// Résultats de recherche pour [query]. Requête vide = liste vide.

final class SearchResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ContactSummaryDto>>,
          List<ContactSummaryDto>,
          FutureOr<List<ContactSummaryDto>>
        >
    with
        $FutureModifier<List<ContactSummaryDto>>,
        $FutureProvider<List<ContactSummaryDto>> {
  /// Résultats de recherche pour [query]. Requête vide = liste vide.
  SearchResultsProvider._({
    required SearchResultsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchResultsHash();

  @override
  String toString() {
    return r'searchResultsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ContactSummaryDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ContactSummaryDto>> create(Ref ref) {
    final argument = this.argument as String;
    return searchResults(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchResultsHash() => r'226dbbdd0b0b6a30276839c75aaeb34a04bd0429';

/// Résultats de recherche pour [query]. Requête vide = liste vide.

final class SearchResultsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ContactSummaryDto>>, String> {
  SearchResultsFamily._()
    : super(
        retry: null,
        name: r'searchResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Résultats de recherche pour [query]. Requête vide = liste vide.

  SearchResultsProvider call(String query) =>
      SearchResultsProvider._(argument: query, from: this);

  @override
  String toString() => r'searchResultsProvider';
}

/// Les groupes de doublons de « Fusionner et corriger ».

@ProviderFor(duplicateGroups)
final duplicateGroupsProvider = DuplicateGroupsProvider._();

/// Les groupes de doublons de « Fusionner et corriger ».

final class DuplicateGroupsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DuplicateGroupDto>>,
          List<DuplicateGroupDto>,
          FutureOr<List<DuplicateGroupDto>>
        >
    with
        $FutureModifier<List<DuplicateGroupDto>>,
        $FutureProvider<List<DuplicateGroupDto>> {
  /// Les groupes de doublons de « Fusionner et corriger ».
  DuplicateGroupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'duplicateGroupsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$duplicateGroupsHash();

  @$internal
  @override
  $FutureProviderElement<List<DuplicateGroupDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DuplicateGroupDto>> create(Ref ref) {
    return duplicateGroups(ref);
  }
}

String _$duplicateGroupsHash() => r'fa50b96fdeabb682c12632129d0b68a58991f481';

/// Le contenu de la corbeille, avec le compte à rebours de chaque fiche.

@ProviderFor(trashEntries)
final trashEntriesProvider = TrashEntriesProvider._();

/// Le contenu de la corbeille, avec le compte à rebours de chaque fiche.

final class TrashEntriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TrashEntryDto>>,
          List<TrashEntryDto>,
          FutureOr<List<TrashEntryDto>>
        >
    with
        $FutureModifier<List<TrashEntryDto>>,
        $FutureProvider<List<TrashEntryDto>> {
  /// Le contenu de la corbeille, avec le compte à rebours de chaque fiche.
  TrashEntriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trashEntriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trashEntriesHash();

  @$internal
  @override
  $FutureProviderElement<List<TrashEntryDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TrashEntryDto>> create(Ref ref) {
    return trashEntries(ref);
  }
}

String _$trashEntriesHash() => r'4308452957c8fccce33539e5012ca381a701d492';
