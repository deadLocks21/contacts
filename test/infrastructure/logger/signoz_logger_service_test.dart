import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:contacts/core/domain/model/log_level.dart';
import 'package:contacts/infrastructure/logger/signoz.logger.service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Le format de transport est le contrat qui nous lie à Signoz : s'il dérive,
/// rien ne casse — les lignes disparaissent simplement des tableaux de bord.
/// D'où des tests sur la charge elle-même, décodée telle qu'elle part.
void main() {
  late List<http.Request> sent;

  /// Client qui retient les requêtes et répond ce qu'on lui demande.
  MockClient recording({int status = 200}) {
    sent = [];
    return MockClient((request) async {
      sent.add(request);
      return http.Response('', status);
    });
  }

  SignozLoggerService service(
    MockClient client, {
    String? key,
    int maxBatchSize = 50,
    int maxQueueSize = 500,
    Map<String, Object?> resource = const {'service.name': 'contacts'},
  }) => SignozLoggerService(
    endpoint: 'https://ingest.example/v1/logs',
    ingestionKey: key,
    resourceAttributes: resource,
    maxBatchSize: maxBatchSize,
    maxQueueSize: maxQueueSize,
    // Assez long pour que la minuterie ne se déclenche jamais pendant un test :
    // c'est `flush()` qui pilote, pas l'horloge.
    flushInterval: const Duration(hours: 1),
    client: client,
  );

  Map<String, dynamic> payloadOf(http.Request request) =>
      jsonDecode(request.body) as Map<String, dynamic>;

  List<dynamic> recordsOf(http.Request request) =>
      payloadOf(request)['resourceLogs'][0]['scopeLogs'][0]['logRecords'] as List<dynamic>;

  test('poste une charge OTLP avec ressource, gravité et corps', () async {
    final client = recording();
    final logger = service(client, resource: {'service.name': 'contacts', 'os.type': 'ios'});

    await logger.log(LogLevel.warn, 'contact.save.rejected', attributes: {'reason': 'blank'});
    await logger.flush();

    expect(sent, hasLength(1));
    expect(sent.single.url.toString(), 'https://ingest.example/v1/logs');

    final resource = payloadOf(sent.single)['resourceLogs'][0]['resource']['attributes'];
    expect(resource, [
      {
        'key': 'service.name',
        'value': {'stringValue': 'contacts'},
      },
      {
        'key': 'os.type',
        'value': {'stringValue': 'ios'},
      },
    ]);

    final record = recordsOf(sent.single).single as Map<String, dynamic>;
    expect(record['severityNumber'], 13);
    expect(record['severityText'], 'WARN');
    expect(record['body'], {'stringValue': 'contact.save.rejected'});
    expect(record['attributes'], [
      {
        'key': 'reason',
        'value': {'stringValue': 'blank'},
      },
    ]);
    // Nanosecondes, en chaîne : un entier JSON déborderait côté collecteur.
    expect(int.parse(record['timeUnixNano'] as String), greaterThan(0));

    await logger.dispose();
  });

  test('encode chaque type d\'attribut dans sa case OTLP', () async {
    final client = recording();
    final logger = service(client);

    await logger.log(
      LogLevel.info,
      'app.started',
      attributes: {
        'texte': 'oui',
        'entier': 3,
        'reel': 1.5,
        'booleen': true,
        'absent': null,
        'autre': Duration.zero,
      },
    );
    await logger.flush();

    final attributes = {
      for (final a in (recordsOf(sent.single).single as Map<String, dynamic>)['attributes'] as List)
        a['key'] as String: a['value'],
    };
    expect(attributes['texte'], {'stringValue': 'oui'});
    expect(attributes['entier'], {'intValue': '3'});
    expect(attributes['reel'], {'doubleValue': 1.5});
    expect(attributes['booleen'], {'boolValue': true});
    // Pas de `null` en OTLP : la clé reste indexée, la valeur est vide.
    expect(attributes['absent'], {'stringValue': ''});
    expect(attributes['autre'], {'stringValue': Duration.zero.toString()});

    await logger.dispose();
  });

  test('joint le type, le message et la pile de l\'exception', () async {
    final client = recording();
    final logger = service(client);

    await logger.log(
      LogLevel.error,
      'contact.save.failed',
      error: const FormatException('mauvais format'),
      stack: StackTrace.fromString('#0 quelque part'),
    );
    await logger.flush();

    final attributes = {
      for (final a in (recordsOf(sent.single).single as Map<String, dynamic>)['attributes'] as List)
        a['key'] as String: a['value']['stringValue'],
    };
    expect(attributes['exception.type'], 'FormatException');
    expect(attributes['exception.message'], contains('mauvais format'));
    expect(attributes['exception.stacktrace'], contains('quelque part'));

    await logger.dispose();
  });

  test('une pile vide ne devient pas un attribut vide', () async {
    final client = recording();
    final logger = service(client);

    // Le cas réel : `Future.error(objet)` — l'objet n'a jamais été levé, il n'a
    // donc pas de pile. Vu tel quel dans un vrai lancement de l'app.
    await logger.log(
      LogLevel.error,
      'dart.uncaught',
      error: StateError('future non rattrapé'),
      stack: StackTrace.empty,
    );
    await logger.flush();

    final keys = [
      for (final a in (recordsOf(sent.single).single as Map<String, dynamic>)['attributes'] as List)
        a['key'] as String,
    ];
    expect(keys, contains('exception.message'));
    expect(keys, isNot(contains('exception.stacktrace')));

    await logger.dispose();
  });

  test('envoie la clé d\'ingestion en en-tête, et rien du tout si elle est vide', () async {
    final withKey = recording();
    final logger = service(withKey, key: 'secret');
    await logger.log(LogLevel.info, 'app.started');
    await logger.flush();
    expect(sent.single.headers['signoz-access-token'], 'secret');
    await logger.dispose();

    final withoutKey = recording();
    final anonymous = service(withoutKey, key: '');
    await anonymous.log(LogLevel.info, 'app.started');
    await anonymous.flush();
    expect(sent.single.headers.containsKey('signoz-access-token'), isFalse);
    await anonymous.dispose();
  });

  test('part de lui-même dès que le lot est plein', () async {
    final client = recording();
    final logger = service(client, maxBatchSize: 3);

    for (var i = 0; i < 3; i++) {
      await logger.log(LogLevel.info, 'app.route');
    }
    // L'envoi est lancé sans être attendu : on laisse la boucle d'événements
    // le mener à son terme.
    await Future<void>.delayed(Duration.zero);

    expect(sent, hasLength(1));
    expect(recordsOf(sent.single), hasLength(3));

    await logger.dispose();
  });

  test('une erreur part sans attendre la minuterie', () async {
    final client = recording();
    final logger = service(client, maxBatchSize: 1000);

    await logger.log(LogLevel.info, 'app.route');
    await Future<void>.delayed(Duration.zero);
    expect(sent, isEmpty, reason: 'le bavardage courant patiente');

    await logger.log(LogLevel.error, 'dart.uncaught');
    await Future<void>.delayed(Duration.zero);

    // Le plantage natif qui suit parfois une erreur emporterait le tampon :
    // elle part tout de suite, et entraîne avec elle ce qui patientait — le
    // contexte des secondes précédentes, précisément ce qu'on veut lire.
    expect(sent, hasLength(1));
    expect(recordsOf(sent.single), hasLength(2));

    await logger.dispose();
  });

  test('sacrifie les plus anciens quand la file déborde', () async {
    final client = recording();
    final logger = service(client, maxBatchSize: 1000, maxQueueSize: 2);

    await logger.log(LogLevel.info, 'premier');
    await logger.log(LogLevel.info, 'deuxieme');
    await logger.log(LogLevel.info, 'troisieme');
    await logger.flush();

    final bodies = [
      for (final r in recordsOf(sent.single)) (r as Map<String, dynamic>)['body']['stringValue'],
    ];
    expect(bodies, ['deuxieme', 'troisieme']);

    await logger.dispose();
  });

  test('ne lève jamais : réseau coupé comme réponse refusée', () async {
    final broken = MockClient((_) async => throw const SocketExceptionStub());
    final logger = service(broken);
    await logger.log(LogLevel.error, 'dart.uncaught');
    await expectLater(logger.flush(), completes);
    await logger.dispose();

    final refused = recording(status: 401);
    final unauthorized = service(refused, key: 'mauvaise-cle');
    await unauthorized.log(LogLevel.error, 'dart.uncaught');
    await expectLater(unauthorized.flush(), completes);
    await unauthorized.dispose();
  });

  test('vider une file vide n\'appelle personne', () async {
    final client = recording();
    final logger = service(client);
    await logger.flush();
    expect(sent, isEmpty);
    await logger.dispose();
  });

  _transportTest();

  test('un service disposé n\'accepte plus rien', () async {
    final client = recording();
    final logger = service(client);
    await logger.dispose();

    await logger.log(LogLevel.info, 'trop.tard');
    await logger.flush();

    expect(sent, isEmpty);
  });
}

/// Le vrai client HTTP, contre un vrai serveur : le [MockClient] des autres cas
/// vérifie ce qu'on lui demande d'envoyer, pas ce qui part réellement sur le
/// réseau. Encodage du corps, en-têtes, méthode et chemin ne se voient qu'ici.
void _transportTest() {
  test('poste réellement sur le réseau, corps JSON et en-têtes compris', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));

    final received = Completer<HttpRequest>();
    final body = Completer<String>();
    server.listen((request) async {
      body.complete(await utf8.decoder.bind(request).join());
      received.complete(request);
      request.response.statusCode = 200;
      await request.response.close();
    });

    final logger = SignozLoggerService(
      endpoint: 'http://${server.address.host}:${server.port}/v1/logs',
      ingestionKey: 'cle-de-test',
      resourceAttributes: const {'service.name': 'contacts'},
      flushInterval: const Duration(hours: 1),
    );
    await logger.log(LogLevel.error, 'dart.uncaught', attributes: {'app.route': '/corbeille'});
    await logger.flush();

    final request = await received.future;
    expect(request.method, 'POST');
    expect(request.uri.path, '/v1/logs');
    expect(request.headers.value('signoz-access-token'), 'cle-de-test');
    expect(request.headers.contentType?.mimeType, 'application/json');

    final decoded = jsonDecode(await body.future) as Map<String, dynamic>;
    final record = decoded['resourceLogs'][0]['scopeLogs'][0]['logRecords'][0];
    expect(record['body'], {'stringValue': 'dart.uncaught'});
    expect(record['severityText'], 'ERROR');

    await logger.dispose();
  });
}

/// Panne réseau, sans dépendre de `dart:io` pour la fabriquer.
class SocketExceptionStub implements Exception {
  const SocketExceptionStub();

  @override
  String toString() => 'SocketExceptionStub: réseau injoignable';
}
