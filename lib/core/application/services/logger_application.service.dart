import 'package:contacts/core/domain/model/log_level.dart';
import 'package:contacts/core/domain/services/logger.service.dart';

/// Façade de confort au-dessus d'un [LoggerService].
///
/// Deux raisons de ne pas appeler le port directement :
///
/// 1. **Écriture** — `logger.info('contact.saved')` se lit mieux que
///    `logger.log(LogLevel.info, 'contact.saved')`, et les cas d'usage restent
///    lisibles.
/// 2. **Contexte** — chaque enregistrement est enrichi d'attributs transverses
///    (carnet système ou simulé, écran courant, identifiant de fiche…) sans que
///    l'appelant ait à les répéter.
///
/// ## Trois couches d'attributs
///
/// À l'émission, les attributs sont fusionnés dans cet ordre — la couche la
/// plus tardive l'emporte en cas de clé commune :
///
/// 1. **Contexte dynamique** — produit par `resolveContext`, réévalué à chaque
///    émission. C'est ce qui permet à l'instance de journal de rester la même
///    pendant toute la vie de l'app tout en portant l'état courant.
/// 2. **Contexte statique** — attaché par [withContext], pour marquer d'un même
///    attribut tous les enregistrements d'une unité de travail (un import, une
///    fusion…).
/// 3. **Attributs de l'appel** — les plus précis, ils gagnent toujours.
class LoggerApplicationService {
  const LoggerApplicationService(
    this._logger, {
    Map<String, Object?> context = const {},
    Map<String, Object?> Function()? resolveContext,
  }) : _staticContext = context,
       _resolveContext = resolveContext;

  final LoggerService _logger;
  final Map<String, Object?> _staticContext;
  final Map<String, Object?> Function()? _resolveContext;

  /// Rend une façade qui ajoute [extra] au contexte statique courant. Le
  /// résolveur dynamique est conservé tel quel.
  LoggerApplicationService withContext(Map<String, Object?> extra) {
    if (extra.isEmpty) return this;
    return LoggerApplicationService(
      _logger,
      context: {..._staticContext, ...extra},
      resolveContext: _resolveContext,
    );
  }

  Future<void> debug(String message, {Map<String, Object?> attrs = const {}}) =>
      _emit(LogLevel.debug, message, attrs: attrs);

  Future<void> info(String message, {Map<String, Object?> attrs = const {}}) =>
      _emit(LogLevel.info, message, attrs: attrs);

  Future<void> warn(
    String message, {
    Map<String, Object?> attrs = const {},
    Object? error,
    StackTrace? stack,
  }) => _emit(LogLevel.warn, message, attrs: attrs, error: error, stack: stack);

  Future<void> error(
    String message, {
    Map<String, Object?> attrs = const {},
    Object? error,
    StackTrace? stack,
  }) => _emit(LogLevel.error, message, attrs: attrs, error: error, stack: stack);

  /// Vide le tampon du service sous-jacent. À appeler quand l'app passe en
  /// arrière-plan, avant que le système ne suspende le processus.
  Future<void> flush() => _logger.flush();

  Future<void> _emit(
    LogLevel level,
    String message, {
    required Map<String, Object?> attrs,
    Object? error,
    StackTrace? stack,
  }) {
    // Un résolveur qui lève ne doit pas emporter l'enregistrement avec lui :
    // mieux vaut un journal sans contexte que pas de journal du tout.
    Map<String, Object?> resolved;
    try {
      resolved = _resolveContext?.call() ?? const {};
    } catch (_) {
      resolved = const {};
    }
    final merged = resolved.isEmpty && _staticContext.isEmpty && attrs.isEmpty
        ? const <String, Object?>{}
        : <String, Object?>{...resolved, ..._staticContext, ...attrs};
    return _logger.log(level, message, attributes: merged, error: error, stack: stack);
  }
}
