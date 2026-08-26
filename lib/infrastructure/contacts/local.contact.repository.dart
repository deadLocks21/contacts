import 'package:contacts/core/application/persistence/entity_codecs.dart';
import 'package:contacts/core/domain/model/contact.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/infrastructure/persistence/local_record_store.dart';

/// Carnet adossé au store local. La même implémentation sert en mémoire (web,
/// tests) et sur sqflite (mobile, desktop) : seul le store change.
class LocalContactRepository implements ContactRepository {
  LocalContactRepository(this._store);

  final LocalRecordStore _store;

  String get _resource => contactCodec.resource;

  @override
  Stream<int> get changes => _store.changes;

  @override
  Future<List<Contact>> listAll({bool includeTrashed = false}) async {
    final records = await _store.list(_resource, includeDeleted: includeTrashed);
    return [for (final r in records) contactCodec.fromJson(r.payload)];
  }

  @override
  Future<List<Contact>> listTrashed() async {
    final records = await _store.listDeleted(_resource);
    return [for (final r in records) contactCodec.fromJson(r.payload)];
  }

  @override
  Future<Contact?> getById(String id) async {
    final record = await _store.get(_resource, id);
    return record == null ? null : contactCodec.fromJson(record.payload);
  }

  @override
  Future<void> save(Contact contact) => saveAll([contact]);

  @override
  Future<void> saveAll(Iterable<Contact> contacts) => _store.upsert(_resource, [
    for (final c in contacts)
      (
        id: contactCodec.idOf(c),
        payload: contactCodec.toJson(c),
        updatedAt: contactCodec.updatedAtOf(c),
        deletedAt: contactCodec.deletedAtOf(c),
      ),
  ]);

  @override
  Future<void> purge(Iterable<String> ids) => _store.purge(_resource, ids);
}
