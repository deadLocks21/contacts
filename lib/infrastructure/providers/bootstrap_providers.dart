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
@Riverpod(keepAlive: true)
Future<void> bootstrap(Ref ref) async {
  await ref.watch(settingsControllerProvider.future);
  await ref.watch(organizeServiceProvider).purgeExpired.execute();
  await DemoSeed(
    ref.watch(contactRepositoryProvider),
    ref.watch(labelRepositoryProvider),
  ).runIfEmpty();
}
