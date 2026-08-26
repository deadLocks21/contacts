import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selection.provider.g.dart';

/// Sélection multiple de la liste de contacts.
///
/// Un appui long ouvre le mode sélection ; la barre de titre bascule alors sur
/// « N sélectionnés » et ses actions. Vider la sélection referme le mode — il
/// n'y a donc pas de drapeau séparé à tenir synchronisé.
@riverpod
class ContactSelection extends _$ContactSelection {
  @override
  Set<String> build() => const {};

  void toggle(String id) {
    final next = {...state};
    if (!next.remove(id)) next.add(id);
    state = next;
  }

  void selectAll(Iterable<String> ids) => state = {...ids};

  void clear() => state = const {};
}
