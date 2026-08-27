import 'package:contacts/core/domain/model/log_level.dart';
import 'package:contacts/core/domain/services/logger.service.dart';

/// Diffuse chaque enregistrement à plusieurs [LoggerService].
///
/// Sert surtout en développement quand une clé Signoz est configurée : la
/// console et Signoz reçoivent la même chose, et il n'y a plus d'écart entre
/// « ce que je vois en local » et « ce qui arrive dans Signoz ».
///
/// Les appels aux enfants sont séquentiels : le volume est trop faible pour que
/// le parallélisme se justifie, et l'ordre reste déterministe dans la console.
///
/// Un enfant qui lève — ce que le contrat de [LoggerService] interdit, mais on
/// ne parie pas là-dessus — est ignoré : un adaptateur en panne ne fait pas
/// taire les autres.
class CompositeLoggerService implements LoggerService {
  CompositeLoggerService(List<LoggerService> children)
    : assert(children.isNotEmpty, 'Un CompositeLoggerService a besoin d\'au moins un enfant'),
      _children = List.unmodifiable(children);

  final List<LoggerService> _children;

  @override
  Future<void> log(
    LogLevel level,
    String message, {
    Map<String, Object?> attributes = const {},
    Object? error,
    StackTrace? stack,
  }) async {
    for (final child in _children) {
      try {
        await child.log(level, message, attributes: attributes, error: error, stack: stack);
      } catch (_) {
        // Ignoré — cf. la remarque de classe.
      }
    }
  }

  @override
  Future<void> flush() async {
    for (final child in _children) {
      try {
        await child.flush();
      } catch (_) {
        // Idem.
      }
    }
  }
}
