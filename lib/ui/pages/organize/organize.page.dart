import 'dart:io';

import 'package:contacts/core/domain/exceptions/contact_exception.dart';
import 'package:contacts/infrastructure/providers/service_providers.dart';
import 'package:contacts/ui/providers/contact_data_providers.dart';
import 'package:contacts/ui/router/app_router.dart';
import 'package:contacts/ui/theme/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

/// L'onglet « Organiser » : la suggestion de fusion, l'import/export, la
/// corbeille et les réglages.
class OrganizePage extends ConsumerWidget {
  const OrganizePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final duplicates = ref.watch(duplicateGroupsProvider).value ?? const [];
    final trashed = ref.watch(trashEntriesProvider).value ?? const [];
    final total = ref.watch(contactListProvider()).value?.total ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Organiser')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            if (duplicates.isNotEmpty) _MergeSuggestion(groupCount: duplicates.length),
            _SectionTitle('Contacts sur cet appareil'),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: Text(total == 1 ? '1 contact' : '$total contacts'),
              subtitle: const Text('Enregistrés localement'),
            ),
            const Divider(height: 24, indent: 16, endIndent: 16),
            _SectionTitle('Gérer les contacts'),
            ListTile(
              leading: const Icon(Icons.merge_type),
              title: const Text('Fusionner et corriger'),
              subtitle: Text(
                duplicates.isEmpty
                    ? 'Aucun doublon détecté'
                    : '${duplicates.length} doublon${duplicates.length > 1 ? 's' : ''} à examiner',
              ),
              onTap: () => context.push(AppRoutes.duplicates),
            ),
            ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: const Text('Importer'),
              subtitle: const Text('Depuis un fichier .vcf'),
              onTap: () => _import(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.file_upload_outlined),
              title: const Text('Exporter'),
              subtitle: const Text('Vers un fichier .vcf'),
              onTap: () => _export(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Corbeille'),
              subtitle: Text(
                trashed.isEmpty
                    ? 'Vide'
                    : '${trashed.length} contact${trashed.length > 1 ? 's' : ''}',
              ),
              onTap: () => context.push(AppRoutes.trash),
            ),
            const Divider(height: 24, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Paramètres'),
              onTap: () => context.push(AppRoutes.settings),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text(
                'Vos contacts ne quittent pas cet appareil.',
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
    final file = picked?.files.firstOrNull;
    if (file == null) return;

    final path = file.path;
    if (path == null) return;
    final source = await File(path).readAsString();

    try {
      final report = await ref.read(organizeServiceProvider).importVCard.execute(source);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${report.imported} contact${report.imported > 1 ? 's' : ''} importé'
            '${report.imported > 1 ? 's' : ''}'
            '${report.labelsCreated > 0 ? ' · ${report.labelsCreated} étiquette'
                      '${report.labelsCreated > 1 ? 's créées' : ' créée'}' : ''}',
          ),
        ),
      );
    } on VCardParseException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final vcf = await ref.read(organizeServiceProvider).exportVCard.execute();
    if (vcf.trim().isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Aucun contact à exporter.')));
      return;
    }

    // On partage un vrai fichier .vcf : c'est le seul format que les autres
    // carnets d'adresses savent ouvrir.
    final directory = Directory.systemTemp;
    final file = File('${directory.path}/contacts.vcf');
    await file.writeAsString(vcf);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], subject: 'contacts.vcf'));
  }
}

/// Carte de suggestion en tête d'écran, comme celle que Google affiche quand
/// il repère des doublons.
class _MergeSuggestion extends StatelessWidget {
  const _MergeSuggestion({required this.groupCount});

  final int groupCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colors.accentSoft, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(Icons.merge_type, color: colors.onAccentSoft),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$groupCount doublon${groupCount > 1 ? 's' : ''} détecté'
                  '${groupCount > 1 ? 's' : ''}',
                  style: TextStyle(color: colors.onAccentSoft, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fusionnez-les pour ne garder qu\'une fiche par personne.',
                  style: TextStyle(color: colors.onAccentSoft, fontSize: 13),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push(AppRoutes.duplicates),
            child: const Text('Voir'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
      child: Text(
        label,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.accent),
      ),
    );
  }
}
