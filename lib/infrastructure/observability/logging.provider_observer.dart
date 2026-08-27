import 'package:contacts/core/application/services/logger_application.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Journalise **tout** provider qui échoue.
///
/// C'est le filet des chemins de lecture : la liste, une fiche, la recherche,
/// les doublons, la corbeille et l'amorçage passent tous par un provider, et une
/// exception y devient un `AsyncError` que l'écran affiche — puis oublie. Sans
/// cet observateur, un carnet qui refuse de se charger ne laisserait aucune
/// trace ailleurs que sous les yeux de l'utilisateur.
///
/// ## Pourquoi deux chemins
///
/// [providerDidFail] ne couvre que les providers qui lèvent **de façon
/// synchrone**. Riverpod 3 ne l'appelle pas quand un `FutureProvider` échoue
/// après un `await` : l'échec devient alors une valeur — un [AsyncValue] en
/// erreur — annoncée par [didUpdateProvider] comme n'importe quel autre état.
/// Or presque toutes les lectures du carnet sont asynchrones : s'en tenir au
/// premier chemin ne journaliserait à peu près rien.
///
/// Les deux chemins peuvent décrire le même échec ; [_lastError] les
/// dédoublonne sur l'identité de l'exception, et s'efface au premier succès pour
/// qu'une panne qui revient soit bien journalisée deux fois.
///
/// Le journal est résolu à l'appel, pas à la construction : l'observateur est
/// passé au [ProviderContainer] qui le porte, il ne peut donc pas en lire un
/// provider avant que celui-ci existe.
final class LoggingProviderObserver extends ProviderObserver {
  LoggingProviderObserver(this._resolveLogger);

  final LoggerApplicationService Function() _resolveLogger;

  /// Coupe-circuit : si c'est le provider de journal lui-même qui échoue,
  /// le journaliser le relancerait à l'infini.
  var _reporting = false;

  /// Dernière exception journalisée, pour ne pas l'écrire deux fois.
  Object? _lastError;

  @override
  void providerDidFail(ProviderObserverContext context, Object error, StackTrace stackTrace) =>
      _report(context, error, stackTrace);

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) =>
      _reportAsyncFailure(context, value);

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) => _reportAsyncFailure(context, newValue);

  void _reportAsyncFailure(ProviderObserverContext context, Object? value) {
    if (value is! AsyncValue) return;
    final error = value.error;
    if (error == null) {
      _lastError = null;
      return;
    }
    _report(context, error, value.stackTrace ?? StackTrace.empty);
  }

  void _report(ProviderObserverContext context, Object error, StackTrace stackTrace) {
    if (_reporting || identical(error, _lastError)) return;
    _reporting = true;
    _lastError = error;
    try {
      _resolveLogger().error(
        'provider.failed',
        attrs: {'provider': context.provider.name ?? context.provider.runtimeType.toString()},
        error: error,
        stack: stackTrace,
      );
    } catch (_) {
      // Un journal en panne ne fait pas tomber l'app — cf. LoggerService.
    } finally {
      _reporting = false;
    }
  }
}
