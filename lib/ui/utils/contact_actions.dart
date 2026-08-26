import 'package:contacts/infrastructure/providers/service_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Actions transverses déclenchées depuis plusieurs écrans : appeler, écrire,
/// partager, confirmer une mise à la corbeille.

/// Compose un numéro.
Future<void> dial(String number) => _launch(Uri(scheme: 'tel', path: number));

/// Ouvre l'application de SMS.
Future<void> sendSms(String number) => _launch(Uri(scheme: 'sms', path: number));

/// Ouvre le client e-mail.
Future<void> sendEmail(String address) => _launch(Uri(scheme: 'mailto', path: address));

/// Ouvre une adresse dans le navigateur.
Future<void> openUrl(String url) =>
    _launch(Uri.parse(url.contains('://') ? url : 'https://$url'));

/// Ouvre une adresse postale dans l'application de cartes.
Future<void> openMap(String address) =>
    _launch(Uri.parse('geo:0,0?q=${Uri.encodeComponent(address)}'));

/// Partage des fiches au format vCard — c'est ainsi que Google Contacts
/// envoie un contact à quelqu'un.
Future<void> shareContacts(WidgetRef ref, {required Set<String> ids}) async {
  final vcf = await ref.read(organizeServiceProvider).exportVCard.execute(ids: ids);
  await SharePlus.instance.share(ShareParams(text: vcf, subject: 'Contacts'));
}

/// Confirme une mise à la corbeille. Renvoie vrai si l'utilisateur a accepté.
Future<bool> confirmMoveToTrash(BuildContext context, {required int count, String? name}) async {
  final title = count == 1
      ? 'Supprimer ${name ?? 'ce contact'} ?'
      : 'Supprimer $count contacts ?';
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: const Text(
        'Le contact part à la corbeille, où il reste 30 jours avant suppression définitive.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
      ],
    ),
  );
  return confirmed ?? false;
}

Future<void> _launch(Uri uri) async {
  if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
}
