import '../models/entry_model.dart';
import 'database_helper.dart';

/// Data source для работы с Entries в БД
class EntryLocalDataSource {
  final DatabaseHelper _dbHelper;

  EntryLocalDataSource(this._dbHelper);

  /// Получить все записи раздела
  Future<List<EntryModel>> getEntriesBySection(String sectionId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'entries',
      where: 'section_id = ?',
      whereArgs: [sectionId],
      orderBy: 'occurred_at DESC',
    );
    return maps.map((map) => EntryModel.fromMap(map)).toList();
  }

  /// Получить записи раздела за период
  Future<List<EntryModel>> getEntriesByPeriod({
    required String sectionId,
    required int startTimestamp,
    required int endTimestamp,
  }) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'entries',
      where: 'section_id = ? AND occurred_at >= ? AND occurred_at <= ?',
      whereArgs: [sectionId, startTimestamp, endTimestamp],
      orderBy: 'occurred_at DESC',
    );
    return maps.map((map) => EntryModel.fromMap(map)).toList();
  }

  /// Получить все записи за период (все разделы)
  Future<List<EntryModel>> getAllEntriesByPeriod({
    required int startTimestamp,
    required int endTimestamp,
  }) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'entries',
      where: 'occurred_at >= ? AND occurred_at <= ?',
      whereArgs: [startTimestamp, endTimestamp],
      orderBy: 'occurred_at DESC',
    );
    return maps.map((map) => EntryModel.fromMap(map)).toList();
  }

  /// Получить запись по id
  Future<EntryModel?> getEntryById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'entries',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return EntryModel.fromMap(maps.first);
  }

  /// Создать запись
  Future<void> insertEntry(EntryModel entry) async {
    final db = await _dbHelper.database;
    await db.insert('entries', entry.toMap());
  }

  /// Обновить запись
  Future<void> updateEntry(EntryModel entry) async {
    final db = await _dbHelper.database;
    await db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  /// Удалить запись
  Future<void> deleteEntry(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Получить количество записей в разделе
  Future<int> getEntryCountBySection(String sectionId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM entries WHERE section_id = ?',
      [sectionId],
    );
    return result.first['count'] as int;
  }
}
