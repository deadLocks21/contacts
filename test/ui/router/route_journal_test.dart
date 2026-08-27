import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:contacts/core/domain/model/log_level.dart';
import 'package:contacts/infrastructure/logger/in_memory.logger.service.dart';
import 'package:contacts/infrastructure/observability/route_tracker.dart';
import 'package:contacts/ui/router/route_journal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// L'écran courant est le contexte que porte **chaque** ligne du journal : sans
/// lui, une erreur dit ce qui a cassé mais jamais où.
void main() {
  late InMemoryLoggerService sink;
  late RouteTracker tracker;

  GoRouter routerWithJournal() {
    sink = InMemoryLoggerService();
    tracker = RouteTracker();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('accueil')),
        ),
        GoRoute(
          path: '/corbeille',
          builder: (_, _) => const Scaffold(body: Text('corbeille')),
        ),
      ],
    );
    addTearDown(router.dispose);
    installRouteJournal(router, logger: LoggerApplicationService(sink), tracker: tracker);
    return router;
  }

  testWidgets('retient l\'écran de départ sans rien écrire de plus', (tester) async {
    final router = routerWithJournal();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(tracker.current, '/');
    // La première route n'a pas de « depuis » : c'est le point de départ.
    expect(sink.records.single.message, 'app.route');
    expect(sink.records.single.level, LogLevel.debug);
    expect(sink.records.single.attributes, isEmpty);
  });

  testWidgets('note chaque changement, d\'où il vient', (tester) async {
    final router = routerWithJournal();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    router.go('/corbeille');
    await tester.pumpAndSettle();

    expect(tracker.current, '/corbeille');
    expect(sink.records.last.attributes['app.route.from'], '/');
  });

  testWidgets('ne répète pas un écran inchangé', (tester) async {
    final router = routerWithJournal();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    router.go('/corbeille');
    await tester.pumpAndSettle();
    router.go('/corbeille');
    await tester.pumpAndSettle();

    expect(sink.messages, ['app.route', 'app.route']);
  });
}
