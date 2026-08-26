import 'package:contacts/core/application/dtos/highlights.dto.dart';
import 'package:contacts/ui/pages/home/widgets/contacts_search_bar.widget.dart';
import 'package:contacts/ui/providers/contact_data_providers.dart';
import 'package:contacts/ui/providers/contact_view.provider.dart';
import 'package:contacts/ui/router/app_router.dart';
import 'package:contacts/ui/theme/app_colors.dart';
import 'package:contacts/ui/widgets/contact_tile.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// L'onglet « Faits marquants » : les favoris, les anniversaires qui
/// approchent, et les fiches récemment touchées.
///
/// Chaque section propose une carte d'amorçage tant qu'elle est vide — c'est
/// ce que fait Google, plutôt que de masquer une section sans contenu.
class HighlightsPage extends ConsumerWidget {
  const HighlightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final highlightsAsync = ref.watch(highlightsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: highlightsAsync.when(
          skipLoadingOnReload: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Erreur : $error')),
          data: (highlights) => ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              ContactsSearchBar(onTap: () => context.push(AppRoutes.search)),
              _SectionHeader(
                'Favoris',
                action: highlights.favorites.isEmpty ? null : 'Voir tout',
                onAction: () {
                  ref.read(contactViewProvider.notifier).showFavorites();
                  context.go(AppRoutes.contacts);
                },
              ),
              if (highlights.favorites.isEmpty)
                _PromptCard(
                  icon: Icons.star_outline,
                  title: 'Ajoutez des favoris',
                  message:
                      'Les contacts que vous mettez en favori apparaissent ici, à portée '
                      'de pouce.',
                  actionLabel: 'Choisir des favoris',
                  onAction: () => context.go(AppRoutes.contacts),
                )
              else
                for (final contact in highlights.favorites)
                  ContactTile(
                    contact: contact,
                    showStar: false,
                    onTap: () => context.push(AppRoutes.contact(contact.id)),
                  ),
              _SectionHeader('Pour vous'),
              if (highlights.birthdays.isEmpty)
                _PromptCard(
                  icon: Icons.cake_outlined,
                  title: 'Ajoutez des anniversaires',
                  message:
                      'Enregistrez la date de naissance de vos contacts pour voir ici '
                      'ceux qui approchent.',
                  actionLabel: 'Ajouter une date',
                  onAction: () => context.push(AppRoutes.newContact),
                )
              else
                for (final birthday in highlights.birthdays) _BirthdayTile(birthday: birthday),
              if (highlights.recents.isNotEmpty) ...[
                _SectionHeader('Récents'),
                for (final contact in highlights.recents)
                  ContactTile(
                    contact: contact,
                    onTap: () => context.push(AppRoutes.contact(contact.id)),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BirthdayTile extends StatelessWidget {
  const _BirthdayTile({required this.birthday});

  final UpcomingBirthdayDto birthday;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final age = birthday.age;
    return ContactTile(
      contact: birthday.contact,
      showStar: false,
      subtitleOverride:
          '${birthday.whenLabel} · ${birthday.date}${age == null ? '' : ' · $age ans'}',
      trailing: Icon(Icons.cake_outlined, size: 20, color: colors.textMuted),
      onTap: () => context.push(AppRoutes.contact(birthday.contact.id)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label, {this.action, this.onAction});

  final String label;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 16, color: colors.textPrimary)),
          ),
          if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
        ],
      ),
    );
  }
}

/// Carte d'amorçage d'une section vide.
class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: colors.accentSoft, shape: BoxShape.circle),
                child: Icon(icon, color: colors.onAccentSoft),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 16, color: colors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(fontSize: 13, color: colors.textMuted, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(onPressed: onAction, child: Text(actionLabel)),
          ),
        ],
      ),
    );
  }
}
