import 'package:contacts/infrastructure/providers/infra_providers.dart';
import 'package:contacts/infrastructure/providers/logger.service_provider.dart';
import 'package:contacts/infrastructure/providers/repository_providers.dart';
import 'package:contacts/infrastructure/providers/service_providers.dart';
import 'package:contacts/infrastructure/providers/settings_providers.dart';
import 'package:contacts/infrastructure/seed/demo_seed.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bootstrap_providers.g.dart';

/// Démarrage de l'app, avant tout affichage : réglages relus, corbeille purgée
/// de ce qui a dépassé 30 jours, carnet de démonstration écrit si le store est
/// vierge.
///
/// La purge se fait ici parce que c'est le seul moment où l'app peut constater
/// l'expiration : sans tâche de fond, une fiche supprimée il y a 31 jours ne
/// disparaît qu'au prochain lancement.
///
/// Chaque étape laisse une trace. Un démarrage est l'endroit où une panne se
/// voit le moins — l'app affiche une roue qui tourne, puis une liste vide — et
/// celui où elle coûte le plus cher. L'échec du provider lui-même est journalisé
/// par [LoggingProviderObserver], inutile de le rattraper ici.
@Riverpod(keepAlive: true)
Future<void> bootstrap(Ref ref) async {
  final logger = ref.watch(loggerProvider);
  final startedAt = DateTime.now();

  await ref.watch(settingsControllerProvider.future);
  // L'accès au carnet se demande avant le premier affichage : la liste ne
  // doit jamais s'afficher vide en attendant une réponse.
  final granted = await ref.watch(contactsPermissionProvider.future);
  if (!granted) {
    // Refus d'accès : l'app fonctionne, mais sur un carnet vide. C'est la
    // première chose à vérifier devant un « je n'ai plus aucun contact ».
    await logger.warn('contacts.permission.denied');
  }

  final purged = await ref.watch(organizeServiceProvider).purgeExpired.execute();

  // Le carnet de démonstration n'a de sens que sur le carnet simulé : sur un
  // téléphone, ce sont les vrais contacts de l'utilisateur qui s'affichent, et
  // y écrire des fiches inventées serait indélicat.
  var seeded = false;
  if (!ref.watch(useDeviceContactsProvider)) {
    seeded = await DemoSeed(
      ref.watch(contactRepositoryProvider),
      ref.watch(labelRepositoryProvider),
    ).runIfEmpty();
  }

  await logger.info(
    'app.bootstrap',
    attrs: {
      'duration_ms': DateTime.now().difference(startedAt).inMilliseconds,
      'contacts.permission': granted,
      'trash.purged': purged,
      'demo.seeded': seeded,
    },
  );
}
