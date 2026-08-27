import 'package:contacts/infrastructure/providers/logger.service_provider.dart';
import 'package:contacts/infrastructure/providers/service_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Actions transverses déclenchées depuis plusieurs écrans : appeler, écrire,
/// partager, confirmer une mise à la corbeille.
///
/// Toutes prennent un `ref` : c'est le prix du journal, et il se paie ici plus
/// qu'ailleurs. Un appui sur « Appeler » qui ne fait rien — parce qu'aucune app
/// ne répond au schéma `tel:` sur cet appareil — ne laisse par nature aucune
/// trace à l'écran. Seul le journal peut dire qu'il s'est passé quelque chose.
///
/// Ce qui est journalisé, c'est le **schéma** de l'URI (`tel`, `mailto`, `geo`)
/// et jamais sa valeur : un numéro ou une adresse n'a rien à faire hors de
/// l'appareil (cf. README, « Observabilité »).

/// Compose un numéro.
Future<void> dial(WidgetRef ref, String number) =>
    _launch(ref, Uri(scheme: 'tel', path: number), 'dial');

/// Ouvre l'application de SMS.
Future<void> sendSms(WidgetRef ref, String number) =>
    _launch(ref, Uri(scheme: 'sms', path: number), 'sms');

/// Ouvre le client e-mail.
Future<void> sendEmail(WidgetRef ref, String address) =>
    _launch(ref, Uri(scheme: 'mailto', path: address), 'email');

/// Ouvre une adresse dans le navigateur.
Future<void> openUrl(WidgetRef ref, String url) =>
    _launch(ref, Uri.parse(url.contains('://') ? url : 'https://$url'), 'website');

/// Ouvre une adresse postale dans l'application de cartes.
Future<void> openMap(WidgetRef ref, String address) =>
    _launch(ref, Uri.parse('geo:0,0?q=${Uri.encodeComponent(address)}'), 'map');

/// Partage des fiches au format vCard — c'est ainsi que Google Contacts
/// envoie un contact à quelqu'un.
Future<void> shareContacts(WidgetRef ref, {required Set<String> ids}) async {
  final logger = ref.read(loggerProvider);
  try {
    final vcf = await ref.read(organizeServiceProvider).exportVCard.execute(ids: ids);
    await SharePlus.instance.share(ShareParams(text: vcf, subject: 'Contacts'));
    await logger.info('contact.shared', attrs: {'contacts.count': ids.length});
  } catch (e, st) {
    await logger.error(
      'contact.share.failed',
      attrs: {'contacts.count': ids.length},
      error: e,
      stack: st,
    );
  }
}

/// Confirme une mise à la corbeille. Renvoie vrai si l'utilisateur a accepté.
Future<bool> confirmMoveToTrash(BuildContext context, {required int count, String? name}) async {
  final title = count == 1 ? 'Supprimer ${name ?? 'ce contact'} ?' : 'Supprimer $count contacts ?';
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

Future<void> _launch(WidgetRef ref, Uri uri, String action) async {
  final logger = ref.read(loggerProvider);
  final attrs = {'action': action, 'uri.scheme': uri.scheme};
  try {
    if (!await canLaunchUrl(uri)) {
      // Aucune app ne répond à ce schéma : sur un émulateur ou une tablette
      // sans composeur, c'est le cas le plus fréquent — et le plus déroutant.
      await logger.warn('action.unsupported', attrs: attrs);
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    await logger.info('action.launched', attrs: attrs);
  } catch (e, st) {
    // Avalée : l'utilisateur n'a rien à réparer, et l'app n'a rien à afficher
    // de plus utile qu'un écran inchangé. La trace, elle, part.
    await logger.error('action.failed', attrs: attrs, error: e, stack: st);
  }
}
