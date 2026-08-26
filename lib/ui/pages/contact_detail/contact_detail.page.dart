import 'package:contacts/core/application/dtos/contact_detail.dto.dart';
import 'package:contacts/infrastructure/providers/service_providers.dart';
import 'package:contacts/ui/pages/contact_detail/widgets/contact_field_rows.widget.dart';
import 'package:contacts/ui/pages/contact_detail/widgets/contact_header.widget.dart';
import 'package:contacts/ui/router/app_router.dart';
import 'package:contacts/ui/theme/app_colors.dart';
import 'package:contacts/ui/utils/contact_actions.dart';
import 'package:contacts/ui/widgets/label_picker.sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:contacts/ui/providers/contact_data_providers.dart';

/// La fiche d'un contact : coordonnées, dates, étiquettes, et les actions qui
/// s'y appliquent.
class ContactDetailPage extends ConsumerWidget {
  const ContactDetailPage({super.key, required this.contactId});

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final detailAsync = ref.watch(contactDetailProvider(contactId));

    return detailAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Erreur : $error')),
      ),
      data: (contact) {
        if (contact == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Ce contact n\'existe plus.')),
          );
        }

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            actions: [
              IconButton(
                key: const Key('starToggle'),
                tooltip: contact.starred ? 'Retirer des favoris' : 'Ajouter aux favoris',
                icon: Icon(
                  contact.starred ? Icons.star : Icons.star_outline,
                  color: contact.starred ? colors.star : null,
                ),
                onPressed: () => ref.read(contactsServiceProvider).toggleStar.execute([
                  contact.id,
                ], starred: !contact.starred),
              ),
              IconButton(
                tooltip: 'Partager',
                icon: const Icon(Icons.share_outlined),
                onPressed: () => shareContacts(ref, ids: {contact.id}),
              ),
              _OverflowMenu(contact: contact),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                if (contact.isTrashed) _TrashBanner(contact: contact),
                ContactHeader(contact: contact),
                if (contact.hasNoDetails)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                    child: Text(
                      'Aucune coordonnée enregistrée pour ce contact.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.textMuted),
                    ),
                  )
                else ...[
                  const DetailSectionTitle('Coordonnées'),
                  ContactFieldRows(
                    icon: Icons.call_outlined,
                    fields: contact.phones,
                    onTap: (field) => dial(field.rawValue),
                    trailingBuilder: (field) => IconButton(
                      tooltip: 'Envoyer un SMS',
                      icon: Icon(Icons.chat_bubble_outline, size: 20, color: colors.accent),
                      onPressed: () => sendSms(field.rawValue),
                    ),
                  ),
                  ContactFieldRows(
                    icon: Icons.mail_outline,
                    fields: contact.emails,
                    onTap: (field) => sendEmail(field.rawValue),
                  ),
                  ContactFieldRows(
                    icon: Icons.location_on_outlined,
                    fields: contact.addresses,
                    onTap: (field) => openMap(field.rawValue),
                  ),
                  ContactFieldRows(icon: Icons.cake_outlined, fields: contact.events),
                  ContactFieldRows(
                    icon: Icons.link,
                    fields: contact.websites,
                    onTap: (field) => openUrl(field.rawValue),
                  ),
                  ContactFieldRows(icon: Icons.people_outline, fields: contact.relations),
                  ContactFieldRows(icon: Icons.forum_outlined, fields: contact.chats),
                  if (contact.notes != null && contact.notes!.isNotEmpty) ...[
                    const DetailSectionTitle('Notes'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(64, 4, 24, 8),
                      child: Text(
                        contact.notes!,
                        style: TextStyle(color: colors.textPrimary, height: 1.4),
                      ),
                    ),
                  ],
                ],
                _LabelsSection(contact: contact),
              ],
            ),
          ),
          floatingActionButton: contact.isTrashed
              ? null
              : FloatingActionButton.extended(
                  key: const Key('editContactFab'),
                  onPressed: () => context.push(AppRoutes.editContact(contact.id)),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Modifier'),
                ),
        );
      },
    );
  }
}

/// Bandeau des fiches à la corbeille : tant qu'elle y est, on ne peut que la
/// restaurer ou la supprimer pour de bon — pas la modifier.
class _TrashBanner extends ConsumerWidget {
  const _TrashBanner({required this.contact});

  final ContactDetailDto contact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceField,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ce contact est à la corbeille',
            style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Il sera supprimé définitivement 30 jours après sa mise à la corbeille.',
            style: TextStyle(color: colors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                onPressed: () => ref.read(organizeServiceProvider).restore.execute([contact.id]),
                child: const Text('Restaurer'),
              ),
              TextButton(
                onPressed: () async {
                  final router = GoRouter.of(context);
                  await ref.read(organizeServiceProvider).deleteForever.execute([contact.id]);
                  if (router.canPop()) router.pop();
                },
                child: Text('Supprimer définitivement', style: TextStyle(color: colors.danger)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Les étiquettes du contact, sous forme de pastilles, et de quoi les changer.
class _LabelsSection extends ConsumerWidget {
  const _LabelsSection({required this.contact});

  final ContactDetailDto contact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DetailSectionTitle('Étiquettes'),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final label in contact.labels)
                Chip(
                  avatar: Icon(Icons.label_outline, size: 18, color: colors.textMuted),
                  label: Text(label.name),
                ),
              ActionChip(
                avatar: Icon(Icons.add, size: 18, color: colors.accent),
                label: Text(
                  contact.labels.isEmpty ? 'Ajouter une étiquette' : 'Modifier',
                  style: TextStyle(color: colors.accent),
                ),
                onPressed: () => showLabelPicker(
                  context,
                  ref,
                  contactIds: {contact.id},
                  initiallyApplied: {for (final l in contact.labels) l.id},
                  partiallyApplied: const {},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Menu « ⋮ » de la fiche.
class _OverflowMenu extends ConsumerWidget {
  const _OverflowMenu({required this.contact});

  final ContactDetailDto contact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        final router = GoRouter.of(context);
        switch (value) {
          case 'labels':
            await showLabelPicker(
              context,
              ref,
              contactIds: {contact.id},
              initiallyApplied: {for (final l in contact.labels) l.id},
              partiallyApplied: const {},
            );
          case 'voicemail':
            await ref
                .read(contactsServiceProvider)
                .setOptions
                .execute(contact.id, sendToVoicemail: !contact.sendToVoicemail);
          case 'delete':
            if (!context.mounted) return;
            final confirmed = await confirmMoveToTrash(
              context,
              count: 1,
              name: contact.displayName.isEmpty ? null : contact.displayName,
            );
            if (!confirmed) return;
            await ref.read(contactsServiceProvider).moveToTrash.execute([contact.id]);
            if (router.canPop()) router.pop();
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'labels', child: Text('Modifier les étiquettes')),
        PopupMenuItem(
          value: 'voicemail',
          child: Text(
            contact.sendToVoicemail
                ? 'Ne plus renvoyer vers la messagerie'
                : 'Renvoyer vers la messagerie vocale',
          ),
        ),
        if (!contact.isTrashed) const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
      ],
    );
  }
}
