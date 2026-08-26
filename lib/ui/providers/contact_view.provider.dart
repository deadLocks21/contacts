import 'package:contacts/core/domain/model/enums.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'contact_view.provider.g.dart';

/// Ce que l'onglet « Contacts » affiche : tout le carnet, les favoris, ou une
/// étiquette — et les puces de filtre actives.
class ContactViewState {
  const ContactViewState({
    this.labelId,
    this.labelName,
    this.starredOnly = false,
    this.filters = const {},
    this.filtersVisible = false,
  });

  final String? labelId;
  final String? labelName;
  final bool starredOnly;
  final Set<ContactFilter> filters;

  /// La rangée de puces n'apparaît qu'après un appui sur l'icône de filtre,
  /// comme chez Google : au repos, la liste occupe tout l'écran.
  final bool filtersVisible;

  /// Libellé du sélecteur de vue, en tête de la barre de filtres.
  String get title => labelName ?? (starredOnly ? 'Favoris' : 'Tous les contacts');

  bool get isFiltered => labelId != null || starredOnly || filters.isNotEmpty;
}

@riverpod
class ContactView extends _$ContactView {
  @override
  ContactViewState build() => const ContactViewState();

  void showAll() =>
      state = ContactViewState(filters: state.filters, filtersVisible: state.filtersVisible);

  void showFavorites() => state = ContactViewState(
    starredOnly: true,
    filters: state.filters,
    filtersVisible: state.filtersVisible,
  );

  void showLabel(String id, String name) => state = ContactViewState(
    labelId: id,
    labelName: name,
    filters: state.filters,
    filtersVisible: state.filtersVisible,
  );

  void toggleFilter(ContactFilter filter) {
    final next = {...state.filters};
    if (!next.remove(filter)) next.add(filter);
    state = ContactViewState(
      labelId: state.labelId,
      labelName: state.labelName,
      starredOnly: state.starredOnly,
      filters: next,
      filtersVisible: state.filtersVisible,
    );
  }

  void toggleFilterBar() => state = ContactViewState(
    labelId: state.labelId,
    labelName: state.labelName,
    starredOnly: state.starredOnly,
    // Replier la rangée efface les puces : garder un filtre actif mais
    // invisible ferait passer la liste pour incomplète.
    filters: state.filtersVisible ? const {} : state.filters,
    filtersVisible: !state.filtersVisible,
  );
}
