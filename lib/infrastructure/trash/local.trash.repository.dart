import 'package:contacts/core/application/persistence/entity_codecs.dart';
import 'package:contacts/core/domain/model/contact.dart';
import 'package:contacts/core/domain/services/trash.repository.dart';
import 'package:contacts/infrastructure/persistence/local_record_store.dart';

/// Corbeille locale — le seul stockage propre à l'app.
///
/// Le carnet du système n'a pas de corbeille : la fiche y est recopiée avant
/// d'être retirée du carnet, et réinsérée à la restauration. La ressource est
/// distincte de celle du carnet simulé, pour que les deux ne se mélangent pas
/// quand ils partagent la même base.
class LocalTrashRepository implements TrashRepository {
  LocalTrashRepository(this._store);

  final LocalRecordStore _store;

  static const _resource = 'trash';

  @override
  Stream<int> get changes => _store.changes;

  @override
  Future<List<Contact>> listAll() async {
    // `includeDeleted` : dans la corbeille, *toutes* les lignes portent un
    // `deletedAt` — c'est ce qui les y met. Les filtrer les masquerait toutes.
    final records = await _store.list(_resource, includeDeleted: true);
    return [for (final r in records) contactCodec.fromJson(r.payload)];
  }

  @override
  Future<Contact?> getById(String id) async {
    final record = await _store.get(_resource, id);
    return record == null ? null : contactCodec.fromJson(record.payload);
  }

  @override
  Future<void> put(Iterable<Contact> contacts) => _store.upsert(_resource, [
    for (final c in contacts)
      (
        id: contactCodec.idOf(c),
        payload: contactCodec.toJson(c),
        updatedAt: contactCodec.updatedAtOf(c),
        deletedAt: contactCodec.deletedAtOf(c),
      ),
  ]);

  @override
  Future<void> remove(Iterable<String> ids) => _store.purge(_resource, ids);
}
