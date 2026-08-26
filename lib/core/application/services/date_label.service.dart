/// Mise en forme des dates en français, sans dépendre d'`intl` : les libellés
/// littéraux imposeraient un `initializeDateFormatting` et une locale chargée,
/// pour trois formats seulement.
abstract final class DateLabel {
  static const months = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];

  /// « 14 février 1990 », ou « 14 février » quand l'année est inconnue.
  static String eventDate(int day, int month, int? year) {
    final base = '$day ${months[month - 1]}';
    return year == null ? base : '$base $year';
  }

  /// « 14/02/1990 ».
  static String short(DateTime date) => '${_pad(date.day)}/${_pad(date.month)}/${date.year}';

  /// Compte à rebours de la corbeille : « Suppression définitive dans 12 jours ».
  static String daysLeft(int days) => switch (days) {
    <= 0 => "Suppression définitive aujourd'hui",
    1 => 'Suppression définitive demain',
    _ => 'Suppression définitive dans $days jours',
  };

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
