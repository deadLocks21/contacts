import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:contacts/core/domain/model/log_level.dart';
import 'package:contacts/core/domain/services/logger.service.dart';
import 'package:http/http.dart' as http;

/// Expédie les enregistrements à une instance Signoz, en OTLP/HTTP.
///
/// Format de transport : la charge JSON `ExportLogsServiceRequest`
/// d'OpenTelemetry, postée sur `<base>/v1/logs`. Signoz accepte nativement
/// l'encodage JSON du protobuf : écrire le corps à la main est plus léger que
/// de tirer `opentelemetry` + `opentelemetry_exporter_otlp_http`, encore
/// rugueux côté Dart.
///
/// ## Attributs de ressource
///
/// Chaque lot est étiqueté des [resourceAttributes] donnés à la construction
/// (`service.name`, `service.version`, `deployment.environment`, `os.type`…).
/// Ils deviennent les colonnes `resource.*` de Signoz, celles sur lesquelles on
/// découpe les tableaux de bord.
///
/// ## Accumulation
///
/// Les enregistrements s'empilent en mémoire et partent :
/// - dès qu'une erreur est journalisée — c'est le seul niveau qui précède
///   souvent la mort du processus, et attendre la minuterie l'emporterait ;
/// - dès que [maxBatchSize] est atteint ;
/// - sinon toutes les [flushInterval], sur minuterie ;
/// - sur appel explicite à [flush] (passage en arrière-plan).
///
/// La pile est plafonnée à [maxQueueSize] pour ne pas enfler indéfiniment quand
/// le réseau reste coupé — ce sont les plus anciens qui sautent.
///
/// ## En cas d'échec
///
/// Les erreurs réseau sont attrapées et signalées par `dart:developer` (surtout
/// pas par [LoggerService], ce serait récursif). Le lot perdu **n'est pas**
/// rejoué : la télémétrie est au mieux, et une file de reprise finirait par
/// empiler des doublons au premier incident passager.
class SignozLoggerService implements LoggerService {
  SignozLoggerService({
    required this.endpoint,
    this.ingestionKey,
    this.resourceAttributes = const {},
    this.flushInterval = const Duration(seconds: 10),
    this.maxBatchSize = 50,
    this.maxQueueSize = 500,
    this.timeout = const Duration(seconds: 10),
    http.Client? client,
  }) : _client = client ?? http.Client() {
    _timer = Timer.periodic(flushInterval, (_) => unawaited(flush()));
  }

  /// URL complète du point d'entrée OTLP, par exemple
  /// `https://ingest.eu.signoz.cloud:443/v1/logs` (Signoz Cloud) ou
  /// `http://10.0.2.2:4318/v1/logs` (émulateur Android vers un collecteur
  /// auto-hébergé sur la machine hôte).
  final String endpoint;

  /// Clé d'ingestion Signoz Cloud, envoyée en en-tête `signoz-access-token`.
  /// `null` ou vide pour une instance auto-hébergée sans authentification.
  final String? ingestionKey;

  /// Attributs de ressource OTLP attachés à chaque lot.
  final Map<String, Object?> resourceAttributes;

  final Duration flushInterval;
  final int maxBatchSize;
  final int maxQueueSize;
  final Duration timeout;

  final http.Client _client;
  final List<_PendingRecord> _buffer = [];
  Timer? _timer;
  var _disposed = false;
  Future<void>? _inflight;

  @override
  Future<void> log(
    LogLevel level,
    String message, {
    Map<String, Object?> attributes = const {},
    Object? error,
    StackTrace? stack,
  }) async {
    if (_disposed) return;
    // Pile pleine : on sacrifie le plus ancien. Ce qui vient de se passer est
    // plus utile que ce qui s'est passé il y a dix minutes.
    if (_buffer.length >= maxQueueSize) _buffer.removeAt(0);
    _buffer.add(
      _PendingRecord(
        timestampNanos: _nowUnixNano(),
        level: level,
        message: message,
        attributes: attributes,
        error: error,
        stack: stack,
      ),
    );
    // Une erreur ne patiente pas : le plantage natif qui la suit parfois
    // emporterait le tampon avec l'isolat. Les envois se coalescent (cf.
    // [flush]), une rafale d'erreurs ne fait donc pas une rafale de requêtes.
    if (_buffer.length >= maxBatchSize || level == LogLevel.error) unawaited(flush());
  }

  @override
  Future<void> flush() async {
    // Deux envois simultanés se rejoignent : un seul lot en vol à la fois.
    if (_inflight != null) return _inflight;
    if (_buffer.isEmpty) return;
    final batch = List<_PendingRecord>.from(_buffer);
    _buffer.clear();
    final future = _ship(batch);
    _inflight = future;
    try {
      await future;
    } finally {
      _inflight = null;
    }
  }

  Future<void> _ship(List<_PendingRecord> batch) async {
    // Une clé vide vaut pas de clé : l'en-tête ne part pas plutôt que de partir
    // vide, qu'un Signoz auto-hébergé sans authentification refuserait.
    final key = (ingestionKey?.isEmpty ?? true) ? null : ingestionKey;
    try {
      final response = await _client
          .post(
            Uri.parse(endpoint),
            headers: {'content-type': 'application/json', 'signoz-access-token': ?key},
            body: jsonEncode(_buildPayload(batch)),
          )
          .timeout(timeout);
      if (response.statusCode >= 300) {
        // Une clé fausse ou un point d'entrée erroné rend un 401/404 sans lever :
        // sans cette branche, l'app croirait journaliser dans le vide.
        _report(
          'signoz : lot de ${batch.length} enregistrement(s) refusé '
          '(HTTP ${response.statusCode}) — abandonné',
        );
      }
    } catch (e, st) {
      // Ne jamais lever : la télémétrie ne fait pas tomber l'app. On passe par
      // la console de développement, pas par LoggerService — ce serait récursif.
      _report(
        'signoz : envoi d\'un lot de ${batch.length} enregistrement(s) échoué — abandonné',
        error: e,
        stack: st,
      );
    }
  }

  void _report(String message, {Object? error, StackTrace? stack}) =>
      developer.log(message, name: 'contacts.logger', level: 900, error: error, stackTrace: stack);

  Map<String, dynamic> _buildPayload(List<_PendingRecord> batch) => {
    'resourceLogs': [
      {
        'resource': {'attributes': _otlpAttributes(resourceAttributes)},
        'scopeLogs': [
          {
            'scope': {'name': 'contacts.app'},
            'logRecords': [for (final record in batch) _otlpRecord(record)],
          },
        ],
      },
    ],
  };

  Map<String, dynamic> _otlpRecord(_PendingRecord record) {
    final attributes = <String, Object?>{...record.attributes};
    if (record.error != null) {
      attributes['exception.type'] = record.error.runtimeType.toString();
      attributes['exception.message'] = record.error.toString();
    }
    // Une pile vide arrive pour de bon : `Future.error(objet)` transporte
    // l'objet sans l'avoir jamais levé, donc sans pile. Mieux vaut l'attribut
    // absent qu'un attribut vide — l'absence, elle, se lit.
    if (record.stack?.toString() case final trace? when trace.isNotEmpty) {
      attributes['exception.stacktrace'] = trace;
    }
    return {
      'timeUnixNano': record.timestampNanos.toString(),
      'severityNumber': record.level.otelSeverityNumber,
      'severityText': record.level.otelSeverityText,
      'body': {'stringValue': record.message},
      'attributes': _otlpAttributes(attributes),
    };
  }

  /// Encode une table plate dans la forme `KeyValue[]` qu'attend OTLP. Les types
  /// inconnus sont convertis plutôt qu'écartés : l'appelant voit toujours
  /// **quelque chose** dans Signoz.
  List<Map<String, dynamic>> _otlpAttributes(Map<String, Object?> map) => [
    for (final entry in map.entries) {'key': entry.key, 'value': _otlpValue(entry.value)},
  ];

  Map<String, dynamic> _otlpValue(Object? value) => switch (value) {
    // OTLP n'a pas de `null` : la chaîne vide garde au moins la clé indexée.
    null => {'stringValue': ''},
    final String s => {'stringValue': s},
    final bool b => {'boolValue': b},
    final int i => {'intValue': i.toString()},
    final double d => {'doubleValue': d},
    _ => {'stringValue': value.toString()},
  };

  int _nowUnixNano() => DateTime.now().microsecondsSinceEpoch * 1000;

  /// Arrête la minuterie et expédie ce qui reste. Fin de vie du provider et
  /// tests seulement.
  Future<void> dispose() async {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    await flush();
    _client.close();
  }
}

class _PendingRecord {
  _PendingRecord({
    required this.timestampNanos,
    required this.level,
    required this.message,
    required this.attributes,
    this.error,
    this.stack,
  });

  final int timestampNanos;
  final LogLevel level;
  final String message;
  final Map<String, Object?> attributes;
  final Object? error;
  final StackTrace? stack;
}
