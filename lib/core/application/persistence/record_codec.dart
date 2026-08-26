/// Traduit une entité du domaine en enregistrement stockable, et retour.
///
/// Le store local ne connaît que des lignes `(resource, id, payload JSON,
/// updated_at, deleted_at)` : une seule table pour tout le carnet, comme dans
/// motorz. Le codec est le seul endroit qui sache ce que contient le payload.
abstract interface class RecordCodec<T> {
  /// Nom de la ressource — la « table logique » (`contacts`, `labels`).
  String get resource;

  String idOf(T entity);

  DateTime updatedAtOf(T entity);

  /// Non nul = ligne à la corbeille (tombstone logique).
  DateTime? deletedAtOf(T entity);

  Map<String, Object?> toJson(T entity);

  T fromJson(Map<String, Object?> json);
}
