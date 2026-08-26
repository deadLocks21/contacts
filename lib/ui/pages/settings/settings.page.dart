import 'package:contacts/core/domain/model/app_theme_mode.dart';
import 'package:contacts/core/domain/model/enums.dart';
import 'package:contacts/infrastructure/providers/settings_providers.dart';
import 'package:contacts/ui/router/app_router.dart';
import 'package:contacts/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Les paramètres d'affichage du carnet.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final settings = ref.watch(currentSettingsProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: SafeArea(
        child: ListView(
          children: [
            _SectionTitle('Affichage'),
            ListTile(
              title: const Text('Trier par'),
              subtitle: Text(settings.sortOrder.label),
              onTap: () => _choose<ContactSortOrder>(
                context,
                title: 'Trier par',
                values: ContactSortOrder.values,
                current: settings.sortOrder,
                labelOf: (v) => v.label,
                onSelected: controller.setSortOrder,
              ),
            ),
            ListTile(
              title: const Text('Format des noms'),
              subtitle: Text(settings.nameFormat.label),
              onTap: () => _choose<NameFormat>(
                context,
                title: 'Format des noms',
                values: NameFormat.values,
                current: settings.nameFormat,
                labelOf: (v) => v.label,
                onSelected: controller.setNameFormat,
              ),
            ),
            ListTile(
              title: const Text('Thème'),
              subtitle: Text(settings.themeMode.label),
              onTap: () => _choose<AppThemeMode>(
                context,
                title: 'Thème',
                values: AppThemeMode.values,
                current: settings.themeMode,
                labelOf: (v) => v.label,
                onSelected: controller.setThemeMode,
              ),
            ),
            const Divider(height: 24, indent: 16, endIndent: 16),
            _SectionTitle('Contacts'),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Corbeille'),
              onTap: () => context.push(AppRoutes.trash),
            ),
            ListTile(
              leading: const Icon(Icons.merge_type),
              title: const Text('Fusionner et corriger'),
              onTap: () => context.push(AppRoutes.duplicates),
            ),
            const Divider(height: 24, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Text(
                'Contacts — carnet d\'adresses local.',
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Boîte de dialogue à choix unique — la forme que prend chaque réglage de
  /// Google Contacts.
  Future<void> _choose<T>(
    BuildContext context, {
    required String title,
    required List<T> values,
    required T current,
    required String Function(T) labelOf,
    required Future<void> Function(T) onSelected,
  }) async {
    final chosen = await showDialog<T>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          RadioGroup<T>(
            groupValue: current,
            onChanged: (v) => Navigator.pop(context, v),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final value in values)
                  RadioListTile<T>(value: value, title: Text(labelOf(value))),
              ],
            ),
          ),
        ],
      ),
    );
    if (chosen != null) await onSelected(chosen);
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
