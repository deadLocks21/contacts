import 'package:contacts/core/application/dtos/contact_detail.dto.dart';
import 'package:contacts/core/application/dtos/contact_list.dto.dart';
import 'package:contacts/core/application/dtos/contact_summary.dto.dart';
import 'package:contacts/core/application/dtos/duplicate_group.dto.dart';
import 'package:contacts/core/application/dtos/highlights.dto.dart';
import 'package:contacts/core/application/dtos/label.dto.dart';
import 'package:contacts/core/application/dtos/trash_entry.dto.dart';
import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/infrastructure/providers/infra_providers.dart';
import 'package:contacts/infrastructure/providers/service_providers.dart';
import 'package:contacts/infrastructure/providers/settings_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'contact_data_providers.g.dart';

/// Toutes les vues du carnet observent [storeChangesProvider] : une écriture,
/// d'où qu'elle vienne, rafraîchit la liste, la fiche ouverte et les compteurs
/// sans que l'écran qui a écrit ait à prévenir les autres.

/// La liste d'accueil, éventuellement restreinte à une étiquette, aux favoris
/// ou aux puces de filtre actives.
@riverpod
Future<ContactListDto> contactList(
  Ref ref, {
  String? labelId,
  bool starredOnly = false,
  Set<ContactFilter> filters = const {},
}) {
  ref.watch(storeChangesProvider);
  return ref
      .watch(contactsServiceProvider)
      .list
      .execute(
        settings: ref.watch(currentSettingsProvider),
        labelId: labelId,
        starredOnly: starredOnly,
        filters: filters,
      );
}

/// Le contenu de l'onglet « Faits marquants ».
@riverpod
Future<HighlightsDto> highlights(Ref ref) {
  ref.watch(storeChangesProvider);
  return ref
      .watch(contactsServiceProvider)
      .highlights
      .execute(settings: ref.watch(currentSettingsProvider));
}

/// La fiche détaillée d'un contact. `null` = la fiche n'existe plus.
@riverpod
Future<ContactDetailDto?> contactDetail(Ref ref, String contactId) {
  ref.watch(storeChangesProvider);
  return ref
      .watch(contactsServiceProvider)
      .get
      .execute(contactId, settings: ref.watch(currentSettingsProvider));
}

/// Les étiquettes et leur nombre de contacts.
@riverpod
Future<List<LabelDto>> labelList(Ref ref) {
  ref.watch(storeChangesProvider);
  return ref.watch(labelsServiceProvider).list.execute();
}

/// Résultats de recherche pour [query]. Requête vide = liste vide.
@riverpod
Future<List<ContactSummaryDto>> searchResults(Ref ref, String query) {
  ref.watch(storeChangesProvider);
  return ref
      .watch(contactsServiceProvider)
      .search
      .execute(query, settings: ref.watch(currentSettingsProvider));
}

/// Les groupes de doublons de « Fusionner et corriger ».
@riverpod
Future<List<DuplicateGroupDto>> duplicateGroups(Ref ref) {
  ref.watch(storeChangesProvider);
  return ref
      .watch(organizeServiceProvider)
      .listDuplicates
      .execute(settings: ref.watch(currentSettingsProvider));
}

/// Le contenu de la corbeille, avec le compte à rebours de chaque fiche.
@riverpod
Future<List<TrashEntryDto>> trashEntries(Ref ref) {
  ref.watch(storeChangesProvider);
  return ref
      .watch(organizeServiceProvider)
      .listTrash
      .execute(settings: ref.watch(currentSettingsProvider));
}
