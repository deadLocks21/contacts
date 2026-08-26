/// Port d'accès au carnet d'adresses du système.
///
/// Distinct du repository à dessein : « le carnet est vide » et « on n'a pas
/// le droit de le lire » sont deux situations différentes, et l'UI ne doit pas
/// annoncer la première quand c'est la seconde.
abstract interface class ContactsAccess {
  /// Demande l'accès si besoin, et rend l'état après réponse.
  Future<bool> request();
}
