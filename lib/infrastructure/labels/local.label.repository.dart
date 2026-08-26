import 'package:contacts/core/application/persistence/entity_codecs.dart';
import 'package:contacts/core/domain/model/contact_label.dart';
import 'package:contacts/core/domain/services/label.repository.dart';
import 'package:contacts/infrastructure/persistence/local_record_store.dart';

/// Étiquettes adossées au store local. Une étiquette supprimée l'est vraiment :
/// il n'y a pas de corbeille pour les étiquettes.
class LocalLabelRepository implements LabelRepository {
  LocalLabelRepository(this._store);

  final LocalRecordStore _store;

  String get _resource => labelCodec.resource;

  @override
  Stream<int> get changes => _store.changes;

  @override
  Future<List<ContactLabel>> listAll() async {
    final records = await _store.list(_resource);
    return [for (final r in records) labelCodec.fromJson(r.payload)];
  }

  @override
  Future<ContactLabel?> getById(String id) async {
    final record = await _store.get(_resource, id);
    return record == null ? null : labelCodec.fromJson(record.payload);
  }

  @override
  Future<void> save(ContactLabel label) => _store.upsert(_resource, [
    (
      id: labelCodec.idOf(label),
      payload: labelCodec.toJson(label),
      updatedAt: labelCodec.updatedAtOf(label),
      deletedAt: null,
    ),
  ]);

  @override
  Future<void> delete(String id) => _store.purge(_resource, [id]);
}
