import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:contacts/infrastructure/persistence/local_record_store.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Nom du fichier de base, dans le répertoire de documents de l'app.
const _databaseName = 'contacts.db';
const _databaseVersion = 1;

/// Ouvre (et migre) la base locale. Sur desktop, `sqflite` passe par FFI.
Future<Database> openContactsDatabase() async {
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  final directory = await getApplicationDocumentsDirectory();
  return openDatabase(
    p.join(directory.path, _databaseName),
    version: _databaseVersion,
    onCreate: (db, _) async {
      // Table unique, payload JSON : le carnet évolue par ajout de champs
      // (cf. les « autres champs » de la fiche), une table par champ imposerait
      // une migration à chacun.
      await db.execute('''
        CREATE TABLE records (
          resource   TEXT NOT NULL,
          id         TEXT NOT NULL,
          payload    TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          deleted_at TEXT,
          PRIMARY KEY (resource, id)
        )
      ''');
      // La liste d'accueil filtre sur « pas à la corbeille » à chaque affichage.
      await db.execute(
        'CREATE INDEX idx_records_resource_deleted ON records (resource, deleted_at)',
      );
    },
  );
}

/// Store local adossé à sqflite — l'implémentation retenue sur mobile et desktop.
class SqfliteLocalRecordStore with RevisionNotifier implements LocalRecordStore {
  SqfliteLocalRecordStore(this._db);

  final Database _db;

  @override
  Future<List<StoredRecord>> list(String resource, {bool includeDeleted = false}) async {
    final rows = await _db.query(
      'records',
      where: includeDeleted ? 'resource = ?' : 'resource = ? AND deleted_at IS NULL',
      whereArgs: [resource],
    );
    return rows.map(_toRecord).toList();
  }

  @override
  Future<List<StoredRecord>> listDeleted(String resource) async {
    final rows = await _db.query(
      'records',
      where: 'resource = ? AND deleted_at IS NOT NULL',
      whereArgs: [resource],
    );
    return rows.map(_toRecord).toList();
  }

  @override
  Future<StoredRecord?> get(String resource, String id) async {
    final rows = await _db.query(
      'records',
      where: 'resource = ? AND id = ?',
      whereArgs: [resource, id],
      limit: 1,
    );
    return rows.isEmpty ? null : _toRecord(rows.first);
  }

  @override
  Future<void> upsert(String resource, Iterable<StoredRecord> records) async {
    if (records.isEmpty) return;
    final batch = _db.batch();
    for (final record in records) {
      batch.insert('records', {
        'resource': resource,
        'id': record.id,
        'payload': jsonEncode(record.payload),
        'updated_at': record.updatedAt.toUtc().toIso8601String(),
        'deleted_at': record.deletedAt?.toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
    notifyChanged();
  }

  @override
  Future<void> purge(String resource, Iterable<String> ids) async {
    if (ids.isEmpty) return;
    final placeholders = List.filled(ids.length, '?').join(', ');
    await _db.delete(
      'records',
      where: 'resource = ? AND id IN ($placeholders)',
      whereArgs: [resource, ...ids],
    );
    notifyChanged();
  }

  static StoredRecord _toRecord(Map<String, Object?> row) => (
    id: row['id']! as String,
    payload: (jsonDecode(row['payload']! as String) as Map).cast<String, Object?>(),
    updatedAt: DateTime.parse(row['updated_at']! as String).toLocal(),
    deletedAt: row['deleted_at'] == null
        ? null
        : DateTime.parse(row['deleted_at']! as String).toLocal(),
  );
}
