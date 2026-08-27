import 'dart:async';

import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:contacts/infrastructure/observability/route_tracker.dart';
import 'package:go_router/go_router.dart';

/// Branche le suivi des écrans : [tracker] retient l'écran affiché, et chaque
/// changement laisse une ligne dans le journal.
///
/// Écouter le `routerDelegate` plutôt que poser un `NavigatorObserver` : les
/// trois onglets sont un `StatefulShellRoute`, chaque branche a son propre
/// navigateur, et un observateur posé à la racine ne verrait aucune navigation
/// interne à un onglet. Le delegate, lui, publie la configuration complète.
///
/// Le chemin est journalisé tel quel, identifiant de fiche compris : savoir
/// quelle fiche était ouverte quand quelque chose a cassé est précisément ce qui
/// rend une erreur reproductible. Un identifiant ne dit rien de la personne —
/// et rien d'autre du carnet ne part dans le journal (cf. README).
void installRouteJournal(
  GoRouter router, {
  required LoggerApplicationService logger,
  required RouteTracker tracker,
}) {
  void onRouteChanged() {
    final location = router.routerDelegate.currentConfiguration.uri.path;
    // Vide tant que le router n'a pas analysé la route initiale — c'est le cas
    // à l'installation, `main()` le branchant avant le premier affichage.
    if (location.isEmpty || location == tracker.current) return;
    final previous = tracker.current;
    // Mis à jour **avant** l'émission : le journal résout `app.route` à chaque
    // ligne, celle-ci doit déjà porter le nouvel écran.
    tracker.current = location;
    unawaited(logger.debug('app.route', attrs: {'app.route.from': ?previous}));
  }

  onRouteChanged();
  router.routerDelegate.addListener(onRouteChanged);
}
