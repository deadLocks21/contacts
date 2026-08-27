/// Retient l'écran affiché, pour que chaque enregistrement de journal parte
/// avec l'endroit où l'utilisateur se trouvait.
///
/// Volontairement nu : un champ, pas de dépendance. C'est le router qui le tient
/// à jour (cf. `installRouteJournal`), et le journal qui le lit à chaque
/// émission. Sans ce relais, le journal devrait connaître go_router — une
/// dépendance de l'UI dont l'infrastructure n'a pas à hériter.
class RouteTracker {
  /// Chemin de l'écran courant (`/organiser`, `/contact/42`…). `null` tant que
  /// la première route n'est pas installée.
  String? current;
}
