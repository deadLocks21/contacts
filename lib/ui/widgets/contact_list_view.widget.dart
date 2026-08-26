import 'package:contacts/core/application/dtos/contact_list.dto.dart';
import 'package:contacts/core/application/dtos/contact_summary.dto.dart';
import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/ui/providers/contact_data_providers.dart';
import 'package:contacts/ui/providers/selection.provider.dart';
import 'package:contacts/ui/router/app_router.dart';
import 'package:contacts/ui/theme/app_colors.dart';
import 'package:contacts/ui/widgets/alphabet_index.widget.dart';
import 'package:contacts/ui/widgets/contact_tile.widget.dart';
import 'package:contacts/ui/widgets/empty_state.widget.dart';
import 'package:contacts/ui/widgets/section_header.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Hauteurs fixes des lignes : elles rendent l'index alphabétique exact — la
/// position d'une section se calcule par simple addition, sans avoir à mesurer
/// des lignes déjà construites.
const _tileHeight = 64.0;
const _headerHeight = 44.0;

/// La liste de contacts découpée en sections, partagée par l'accueil, la vue
/// d'une étiquette et les favoris.
///
/// Elle porte aussi la sélection multiple : un appui long ouvre le mode, et
/// tant qu'il est ouvert un appui simple coche au lieu d'ouvrir la fiche.
class ContactListView extends ConsumerStatefulWidget {
  const ContactListView({
    super.key,
    this.labelId,
    this.starredOnly = false,
    this.filters = const {},
    this.header,
    this.emptyState,
  });

  final String? labelId;
  final bool starredOnly;
  final Set<ContactFilter> filters;

  /// Contenu défilant posé au-dessus de la liste (la barre de recherche).
  final Widget? header;

  final Widget? emptyState;

  @override
  ConsumerState<ContactListView> createState() => _ContactListViewState();
}

class _ContactListViewState extends ConsumerState<ContactListView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Fait défiler jusqu'à l'en-tête [letter] : on additionne la hauteur de
  /// tout ce qui le précède.
  void _jumpTo(String letter, ContactListDto list) {
    var offset = 0.0;
    for (final section in list.sections) {
      if (section.header == letter) break;
      offset += _headerHeight + section.contacts.length * _tileHeight;
    }
    final max = _scrollController.position.maxScrollExtent;
    _scrollController.jumpTo(offset.clamp(0, max));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final selection = ref.watch(contactSelectionProvider);
    final listAsync = ref.watch(
      contactListProvider(
        labelId: widget.labelId,
        starredOnly: widget.starredOnly,
        filters: widget.filters,
      ),
    );

    return listAsync.when(
      // Un enregistrement recharge la liste : on garde l'ancienne à l'écran
      // plutôt que de faire clignoter un indicateur de chargement.
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Erreur : $error')),
      data: (list) {
        if (list.isEmpty) {
          return CustomScrollView(
            slivers: [
              if (widget.header != null) SliverToBoxAdapter(child: widget.header),
              SliverFillRemaining(
                hasScrollBody: false,
                child:
                    widget.emptyState ??
                    const EmptyState(
                      icon: Icons.person_outline,
                      title: 'Aucun contact',
                      message: 'Appuyez sur « Créer un contact » pour commencer votre carnet.',
                    ),
              ),
            ],
          );
        }

        final rows = _flatten(list);

        return Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                if (widget.header != null) SliverToBoxAdapter(child: widget.header),
                SliverPadding(
                  // Réserve la colonne de l'index : sans elle, les noms longs
                  // et l'étoile des favoris passeraient dessous.
                  padding: const EdgeInsets.only(right: 24),
                  sliver: SliverList.builder(
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      return switch (row) {
                        _HeaderRow(:final label) => SizedBox(
                          height: _headerHeight,
                          child: SectionHeader(label),
                        ),
                        _ContactRow(:final contact) => SizedBox(
                          height: _tileHeight,
                          child: ContactTile(
                            contact: contact,
                            selected: selection.contains(contact.id),
                            onTap: () => _onTap(contact, selection.isNotEmpty),
                            onLongPress: () =>
                                ref.read(contactSelectionProvider.notifier).toggle(contact.id),
                          ),
                        ),
                      };
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
                    child: Text(
                      list.total == 1 ? '1 contact' : '${list.total} contacts',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.textMuted, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              // Sous la barre de recherche et la barre de filtres : l'index ne
              // doit recouvrir ni l'avatar du compte ni les boutons de filtre.
              top: 136,
              bottom: 96,
              right: 2,
              child: AlphabetIndex(
                letters: list.alphabet,
                onSelected: (letter) => _jumpTo(letter, list),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onTap(ContactSummaryDto contact, bool selectionActive) {
    if (selectionActive) {
      ref.read(contactSelectionProvider.notifier).toggle(contact.id);
      return;
    }
    context.push(AppRoutes.contact(contact.id));
  }

  /// Aplatit les sections en lignes — en-têtes et contacts mêlés — pour un
  /// `SliverList` unique, seul moyen de garder un défilement continu.
  List<_Row> _flatten(ContactListDto list) => [
    for (final section in list.sections) ...[
      _HeaderRow(section.header),
      for (final contact in section.contacts) _ContactRow(contact),
    ],
  ];
}

sealed class _Row {
  const _Row();
}

class _HeaderRow extends _Row {
  const _HeaderRow(this.label);
  final String label;
}

class _ContactRow extends _Row {
  const _ContactRow(this.contact);
  final ContactSummaryDto contact;
}
