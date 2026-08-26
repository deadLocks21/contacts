import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/ui/pages/home/widgets/labels.sheet.dart';
import 'package:contacts/ui/providers/contact_data_providers.dart';
import 'package:contacts/ui/providers/contact_view.provider.dart';
import 'package:contacts/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// La barre sous la recherche : le sélecteur de vue à gauche (« Tous les
/// contacts »), l'accès aux étiquettes et le dépliage des puces de filtre à
/// droite.
class ContactsFilterBar extends ConsumerWidget {
  const ContactsFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final view = ref.watch(contactViewProvider);
    final controller = ref.read(contactViewProvider.notifier);
    final labels = ref.watch(labelListProvider).value ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
          child: Row(
            children: [
              PopupMenuButton<String>(
                key: const Key('viewSelector'),
                tooltip: 'Changer de vue',
                onSelected: (value) => switch (value) {
                  'all' => controller.showAll(),
                  'favorites' => controller.showFavorites(),
                  _ => controller.showLabel(value, labels.firstWhere((l) => l.id == value).name),
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'all', child: Text('Tous les contacts')),
                  const PopupMenuItem(value: 'favorites', child: Text('Favoris')),
                  if (labels.isNotEmpty) const PopupMenuDivider(),
                  for (final label in labels)
                    PopupMenuItem(value: label.id, child: Text(label.name)),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        view.starredOnly
                            ? Icons.star_outline
                            : view.labelId != null
                            ? Icons.label_outline
                            : Icons.people_outline,
                        size: 20,
                        color: colors.textPrimary,
                      ),
                      const SizedBox(width: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 180),
                        child: Text(
                          view.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16, color: colors.textPrimary),
                        ),
                      ),
                      Icon(Icons.expand_more, size: 20, color: colors.textPrimary),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                key: const Key('labelsButton'),
                tooltip: 'Étiquettes',
                icon: const Icon(Icons.label_outline),
                onPressed: () => showLabelsSheet(context, ref),
              ),
              IconButton(
                key: const Key('filtersButton'),
                tooltip: view.filtersVisible ? 'Masquer les filtres' : 'Filtrer',
                isSelected: view.filtersVisible,
                icon: const Icon(Icons.filter_list),
                onPressed: controller.toggleFilterBar,
              ),
            ],
          ),
        ),
        if (view.filtersVisible)
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final filter in ContactFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(_iconOf(filter), size: 18, color: colors.textMuted),
                      label: Text(filter.label),
                      selected: view.filters.contains(filter),
                      selectedColor: colors.accentSoft,
                      showCheckmark: false,
                      side: BorderSide(color: colors.outline),
                      backgroundColor: Colors.transparent,
                      onSelected: (_) => controller.toggleFilter(filter),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  static IconData _iconOf(ContactFilter filter) => switch (filter) {
    ContactFilter.avecTelephone => Icons.call_outlined,
    ContactFilter.avecEmail => Icons.mail_outline,
    ContactFilter.avecSociete => Icons.business_outlined,
  };
}
