import 'dart:async';
import 'dart:convert';

/// Une ligne du store local.
typedef StoredRecord = ({
  String id,
  Map<String, Object?> payload,
  DateTime updatedAt,
  DateTime? deletedAt,
});

/// Store local — **source de vérité** du carnet. Une seule table logique pour
/// toutes les ressources (`contacts`, `labels`), le contenu voyageant en JSON
/// (cf. `RecordCodec`).
abstract interface class LocalRecordStore {
  /// Numéro de révision monotone, émis à chaque écriture.
  Stream<int> get changes;

  Future<List<StoredRecord>> list(String resource, {bool includeDeleted = false});

  /// Uniquement les lignes à la corbeille.
  Future<List<StoredRecord>> listDeleted(String resource);

  /// Une ligne précise, corbeille comprise.
  Future<StoredRecord?> get(String resource, String id);

  Future<void> upsert(String resource, Iterable<StoredRecord> records);

  /// Suppression réelle (par opposition au `deletedAt` de la corbeille).
  Future<void> purge(String resource, Iterable<String> ids);
}

/// Diffuseur de révisions partagé par les implémentations.
mixin RevisionNotifier {
  final _controller = StreamController<int>.broadcast();
  var _revision = 0;

  Stream<int> get changes => _controller.stream;

  void notifyChanged() => _controller.add(++_revision);

  void disposeRevisions() => _controller.close();
}

/// Implémentation mémoire — utilisée sur le web, dans les tests, et tant que
/// la base sqflite n'a pas pu s'ouvrir.
class InMemoryLocalRecordStore with RevisionNotifier implements LocalRecordStore {
  final _rows = <String, Map<String, StoredRecord>>{};

  Map<String, StoredRecord> _table(String resource) => _rows.putIfAbsent(resource, () => {});

  @override
  Future<List<StoredRecord>> list(String resource, {bool includeDeleted = false}) async => [
    for (final r in _table(resource).values)
      if (includeDeleted || r.deletedAt == null) r,
  ];

  @override
  Future<List<StoredRecord>> listDeleted(String resource) async => [
    for (final r in _table(resource).values)
      if (r.deletedAt != null) r,
  ];

  @override
  Future<StoredRecord?> get(String resource, String id) async => _table(resource)[id];

  @override
  Future<void> upsert(String resource, Iterable<StoredRecord> records) async {
    if (records.isEmpty) return;
    final table = _table(resource);
    for (final record in records) {
      // Copie défensive du payload : l'appelant garde une référence sur la map
      // qu'il vient de construire, et pourrait la muter après coup.
      table[record.id] = (
        id: record.id,
        payload: jsonDecode(jsonEncode(record.payload)) as Map<String, Object?>,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
      );
    }
    notifyChanged();
  }

  @override
  Future<void> purge(String resource, Iterable<String> ids) async {
    if (ids.isEmpty) return;
    final table = _table(resource);
    for (final id in ids) {
      table.remove(id);
    }
    notifyChanged();
  }
}
