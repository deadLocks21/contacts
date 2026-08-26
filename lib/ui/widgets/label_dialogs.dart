import 'package:contacts/core/domain/exceptions/contact_exception.dart';
import 'package:contacts/infrastructure/providers/service_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Boîtes de dialogue des étiquettes, partagées par le tiroir, la page d'une
/// étiquette et la feuille de sélection.

/// Demande un nom et crée l'étiquette. Renvoie son identifiant, ou `null` si
/// l'utilisateur a annulé.
Future<String?> createLabelDialog(BuildContext context, WidgetRef ref) async {
  final name = await _promptLabelName(
    context,
    title: 'Créer une étiquette',
    confirmLabel: 'Créer',
  );
  if (name == null || !context.mounted) return null;

  try {
    return await ref.read(labelsServiceProvider).create.execute(name);
  } on LabelAlreadyExistsException catch (e) {
    if (context.mounted) _toast(context, e.message);
    return null;
  }
}

/// Renomme une étiquette existante.
Future<void> renameLabelDialog(
  BuildContext context,
  WidgetRef ref, {
  required String labelId,
  required String currentName,
}) async {
  final name = await _promptLabelName(
    context,
    title: 'Renommer l\'étiquette',
    confirmLabel: 'Enregistrer',
    initialValue: currentName,
  );
  if (name == null || !context.mounted) return;

  try {
    await ref.read(labelsServiceProvider).rename.execute(labelId, name);
  } on ContactException catch (e) {
    if (context.mounted) _toast(context, e.message);
  }
}

/// Confirme puis supprime une étiquette. Renvoie vrai si elle a été supprimée.
Future<bool> deleteLabelDialog(
  BuildContext context,
  WidgetRef ref, {
  required String labelId,
  required String name,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Supprimer « $name » ?'),
      content: const Text('Les contacts qui portent cette étiquette ne seront pas supprimés.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
      ],
    ),
  );
  if (confirmed != true) return false;
  await ref.read(labelsServiceProvider).delete.execute(labelId);
  return true;
}

Future<String?> _promptLabelName(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String initialValue = '',
}) async {
  final controller = TextEditingController(text: initialValue);
  final name = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'Nom de l\'étiquette'),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  controller.dispose();
  final trimmed = name?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}

void _toast(BuildContext context, String message) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
