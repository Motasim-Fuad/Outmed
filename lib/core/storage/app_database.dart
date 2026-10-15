import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._(this._db);

  static const version = 1;
  final Database _db;

  static Future<AppDatabase> open() async {
    final directory = await getApplicationDocumentsDirectory();
    final db = await openDatabase(
      p.join(directory.path, 'outmed.db'),
      version: version,
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE cache (bucket TEXT NOT NULL, id TEXT NOT NULL, payload TEXT NOT NULL, PRIMARY KEY (bucket, id))',
        );
        await database.execute(
          'CREATE TABLE sync_queue (id INTEGER PRIMARY KEY AUTOINCREMENT, bucket TEXT NOT NULL, payload TEXT NOT NULL)',
        );
        await database.execute(
          'CREATE TABLE flags (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
        );
      },
    );
    return AppDatabase._(db);
  }

  Future<void> writeBucket(
    String bucket,
    Map<String, Map<String, Object?>> rows,
  ) async {
    final batch = _db.batch()
      ..delete('cache', where: 'bucket = ?', whereArgs: [bucket]);
    for (final entry in rows.entries) {
      batch.insert('cache', {
        'bucket': bucket,
        'id': entry.key,
        'payload': jsonEncode(entry.value),
      });
    }
    await batch.commit(noResult: true);
  }

  Future<void> writeEntry(
    String bucket,
    String id,
    Map<String, Object?> payload,
  ) {
    return _db.insert(
      'cache',
      {'bucket': bucket, 'id': id, 'payload': jsonEncode(payload)},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, Map<String, Object?>>> readEntries(String bucket) async {
    final rows = await _db.query(
      'cache',
      where: 'bucket = ?',
      whereArgs: [bucket],
    );
    return {
      for (final row in rows)
        row['id']! as String: Map<String, Object?>.from(
          jsonDecode(row['payload']! as String) as Map,
        ),
    };
  }

  Future<void> clearBucket(String bucket) {
    return _db.delete('cache', where: 'bucket = ?', whereArgs: [bucket]);
  }

  Future<List<Map<String, Object?>>> readBucket(String bucket) async {
    final rows = await _db.query(
      'cache',
      where: 'bucket = ?',
      whereArgs: [bucket],
    );
    return rows.map((row) {
      final decoded = jsonDecode(row['payload']! as String);
      return Map<String, Object?>.from(decoded as Map);
    }).toList();
  }

  Future<void> enqueue(String bucket, Map<String, Object?> payload) {
    return _db.insert('sync_queue', {
      'bucket': bucket,
      'payload': jsonEncode(payload),
    });
  }

  Future<List<Map<String, Object?>>> pending() async {
    final rows = await _db.query('sync_queue', orderBy: 'id ASC');
    return rows
        .map(
          (row) => {
            'id': row['id'],
            'bucket': row['bucket'],
            'payload': jsonDecode(row['payload']! as String),
          },
        )
        .toList();
  }

  Future<void> removeQueued(int id) {
    return _db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveFlag(String key, String value) {
    return _db.insert('flags', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> readFlag(String key) async {
    final rows = await _db.query(
      'flags',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }
}
