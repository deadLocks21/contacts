/// Gravité d'un enregistrement de journal.
///
/// Les valeurs reprennent l'échelle `SeverityNumber` d'OpenTelemetry, celle que
/// Signoz affiche : l'adaptateur n'a ainsi aucune traduction à inventer.
///
/// | Niveau | severityNumber | severityText |
/// |--------|---------------:|--------------|
/// | debug  | 5              | DEBUG        |
/// | info   | 9              | INFO         |
/// | warn   | 13             | WARN         |
/// | error  | 17             | ERROR        |
///
/// Volontairement court : le carnet n'a pas l'usage d'un `trace` ni d'un
/// `fatal`, et en ajouter plus tard ne casserait rien.
enum LogLevel {
  debug(5, 'DEBUG'),
  info(9, 'INFO'),
  warn(13, 'WARN'),
  error(17, 'ERROR');

  const LogLevel(this.otelSeverityNumber, this.otelSeverityText);

  /// Gravité numérique OpenTelemetry, celle qu'attend l'export OTLP.
  final int otelSeverityNumber;

  /// Gravité textuelle OpenTelemetry, affichée telle quelle par Signoz.
  final String otelSeverityText;
}
