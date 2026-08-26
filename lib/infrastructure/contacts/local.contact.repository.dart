import 'package:contacts/core/application/persistence/entity_codecs.dart';
import 'package:contacts/core/domain/model/contact.dart';
import 'package:contacts/core/domain/services/contact.repository.dart';
import 'package:contacts/infrastructure/persistence/local_record_store.dart';

/// Carnet d'adresses simulé, adossé au store local.
///
/// Doublure du carnet du système là où il n'y en a pas — développement sur
/// desktop et tests. Le seed de démonstration l'alimente pour que l'UI reste
/// travaillable sans téléphone.
class LocalContactRepository implements ContactRepository {
  LocalContactRepository(this._store);

  final LocalRecordStore _store;

  String get _resource => contactCodec.resource;

  @override
  Stream<int> get changes => _store.changes;

  @override
  Future<List<Contact>> listAll() async {
    final records = await _store.list(_resource);
    return [for (final r in records) contactCodec.fromJson(r.payload)];
  }

  @override
  Future<Contact?> getById(String id) async {
    final record = await _store.get(_resource, id);
    return record == null ? null : contactCodec.fromJson(record.payload);
  }

  @override
  Future<String> save(Contact contact) async {
    await saveAll([contact]);
    return contact.id.value;
  }

  @override
  Future<void> saveAll(Iterable<Contact> contacts) => _store.upsert(_resource, [
    for (final c in contacts)
      (
        id: contactCodec.idOf(c),
        payload: contactCodec.toJson(c),
        updatedAt: contactCodec.updatedAtOf(c),
        deletedAt: null,
      ),
  ]);

  @override
  Future<void> delete(Iterable<String> ids) => _store.purge(_resource, ids);
}
